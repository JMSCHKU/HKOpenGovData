(function() {

    var width = 1200;
    var origHeight = 2800;
    var height = origHeight;
    var minYear = 2004;
    var maxYear = 2012;

    var currentSelection = null;
    var defaultSelectionIndex = 0;
    var init = true;
    var initDuration = 2000, normalDuration = 2000;
    var startStation = "Central/Western";
    var currentStation = startStation;
    var maxApiValue = 180;
    var coefCompact = 0.3;
    var coefApiValue = 0.5;
    var increment = 20 / coefApiValue;
    var incrCompact = 2;
    var cooldownBarsMouseOut = false;
    var cooldownBarsMouseOver = false;
    var colorify = true;
    var sorted = false;

    height = (maxYear - minYear + 1) * (maxApiValue + increment) * coefApiValue;
    if (colorify) height = height * coefCompact;
    var svg = d3.select("#g").append("svg")
	.attr("width", width)
	.attr("height", height);

    queue()
        .defer(d3.csv, "metob_daily.csv")
        .defer(d3.csv, "api_daily.csv")
        .defer(d3.csv, "api_today.csv")
        .defer(d3.csv, "stations.csv")
        .await(ready);

    function ready(error, weather, airpollution, airpollution_now, stations) {
        
        function getStnObjFromName (station) {
            for (var i=0; i<stations.length; i++) {
                if (stations[i].station == station) return stations[i];
            }
            return null;
        }

        /* Add the latest current hourly observation */
        for (var i=airpollution_now.length-1; i>=0; i--) {
            if (airpollution_now[i][startStation] == undefined || airpollution_now[i][startStation] == 0) continue; // look for the newest with valid start station value
            airpollution_now[i]["Date"] = airpollution_now[i].recorded;
            airpollution.push(airpollution_now[i]);
            break; // add only the latest
        }
        maxYear = Number(airpollution[airpollution.length-1]["Date"].substr(0,4))
        height = (maxYear - minYear + 1) * (maxApiValue + increment);

        /* Declare scales */
        var ylong = d3.scale.linear()
            .domain([maxYear, minYear])
            .range([maxApiValue+increment,height]);
        var ycompact = d3.scale.linear()
            .domain([maxYear, minYear])
            .range([(maxApiValue+increment)*coefCompact,height*coefCompact]);
        var hcompact = d3.scale.linear()
            .domain([0,10])
            .range([0,1])
        var y = function(num) {
            var yval = 0;
            if (colorify) yval = ycompact(num);
            else yval = ylong(num);
            return (yval * coefApiValue);
        }
        var h = function(num) {
            var hval = 0;
            if (colorify) hval = 20;
            else hval = num;
            return hval * coefApiValue;
        }
        var xfunc = function(d) {
            if (sorted) return xsorted(d);
            else return xdate(d);
        }
        var xdate = function(d) {
            var mydate = d.date;
            if (mydate == undefined) mydate = d["Date"];
            return 1080 - (Number(d3.time.format("%j")(mydate))) * 3 + (12 - Number(d3.time.format("%m")(mydate))) * 1;
        }
        var xsorted = function(d) {
            return d.order * 3;
        }

        /* Populate menu */
        var menu = d3.select("select")
            .on("change", changeAirPollutionData);
        menu.selectAll("option")
            .data(stations)
        .enter().append("option")
            .text(function(d) {var name=d.station; if (d.station=="Causeway Bay"||d.station=="Central"||d.station=="Mong Kok") name += " (roadside)";return name;})
            .attr("value", function(d) {return d.station;});
        menu.property("value", startStation);
        var stnobj = getStnObjFromName(startStation);
        if (stnobj.characteristics.length > 0) d3.select("#station-desc").html(stnobj.characteristics);
        else d3.select("#station-desc").html("");

        /* Year labels */
        var yearLabels = svg.selectAll("text.year-label")
            .data(d3.range(minYear+1,maxYear+1))
            .enter()
            .append("text")
            .text(function(d){return d;})
            .attr("class","year-label")
            .attr("x",1100)
            .attr("y",function(d){return y(d);});

        /* Reformat the data */
        var ymdFormat = d3.time.format("%Y-%m-%d");
        var ymdhmFormat = d3.time.format("%Y-%m-%d %H:%M");
        var hmFormat = d3.time.format("%H:%M");
        weather.forEach(function(d) {
            for (x in d) {
                if (x == "date") {
                    d.date = ymdFormat.parse(d.date);
                } else {
                    try {
                        d[x] = +d[x];
                    } catch (e) {
                    }
                }
            }
        });
        airpollution.forEach(function(d) {
            if (d["hour"] !== undefined) {
                for (x in d) {
                    if (x.toLowerCase() == "date") {
                        d[x] = ymdhmFormat.parse(d[x]);
                    } else {
                        d[x] = +d[x];
                        d[x + " Average"] = +d[x];
                    }
                }
                d["hourly"] = true;
            } else {
                for (x in d) {
                    if (x == "Date") {
                        d["Date"] = ymdFormat.parse(d["Date"]);
                    } else {
                        d[x] = +d[x];
                    }
                }
                d["hourly"] = false;
            }
        });

        /* Sort and re-sort to get data order */
        function sortAirPollution (station) {
            airpollution.sort(function(a,b) { return b[station + " Average"] - a[station + " Average"]; });
            airpollutionOrderByYear = {};
            for (var i=0; i<airpollution.length; i++) {
                var myyear = d3.time.format("%Y")(airpollution[i]["Date"]);
                if (airpollutionOrderByYear[myyear] == undefined) airpollutionOrderByYear[myyear] = [];
                airpollutionOrderByYear[myyear].push(airpollution[i]["Date"]);
                airpollution[i]["order"] = airpollutionOrderByYear[myyear].length - 1;
            }
            airpollution.sort(function(a,b) { return (+a["Date"]) - (+b["Date"]); });
        }
        sortAirPollution (startStation);

        /* Re-nest the data */
        var weatherByYear = d3.nest()
            .key(function(d) { 
                return Number(d3.time.format("%Y")(d.date));
            })
            .map(weather);
        var airpollutionByYear = d3.nest()
            .key(function(d) { return Number(d3.time.format("%Y")(d["Date"])); })
            .map(airpollution);

        /* Build the bars */
        function barMouseOver (d, i) {
            clearInterval(cooldownBarsMouseOut);
            var apiValue = d[currentStation + " Average"];
            if (apiValue == 0) apiValue = "N/A";
            mouseOverText.text("API: " + apiValue)
                .attr("x", Math.max(22, xfunc(d)))
                .attr("y", y(Number(d3.time.format("%Y")(d["Date"]))) - (h(180) + 5));
            dateString = ymdFormat(d["Date"]);
            marginDateTextLeft = 32;
            if (d["hourly"]) {
                dateString = ymdhmFormat(d["Date"])
                now = new Date();
                if (now.getDate() == dateString.substr(8,2)) dateString = "Today " + hmFormat(d["Date"]);
                dateString = dateString.replace(/ /, " at ");
                marginDateTextLeft = 40;
            }
            mouseOverDateText.text(dateString)
                .attr("x", Math.max(marginDateTextLeft, xfunc(d)))
                .attr("y", y(Number(d3.time.format("%Y")(d["Date"]))) + 12);
            d3.selectAll(".bar-under")
                .style("fill-opacity", "0");
            d3.select("#bar-under-" + ymdFormat(d["Date"]).replace(/-/g,""))
                .style("fill-opacity", "1");
            mouseOverDateText
            .on("click", function(d) {
                window.open("http://www.epd-asg.gov.hk/english/24api/"+(currentStation.replace(/[ \/]+/g,"_"))+".html");
            })
            .style("cursor", "pointer");
        }
        function barMouseOut (d, i) {
            cooldownBarsMouseOut = setInterval(function(){
                barMouseOver(airpollution[airpollution.length-1], i);
            }, 10);
        }
        var gBars = svg.selectAll("g.bar")
            .data(airpollution)
        .enter().append("g")
            .attr("transform", function(d,i) {return "translate("+xfunc(d,i)+","+y(Number(d3.time.format("%Y")(d["Date"])))+")";})
            .on("mouseover", barMouseOver)
            .on("mouseout", barMouseOut);
        var barsUnder = gBars.append("rect")
            .attr("class", function(d) { var val = "bar-under "; if (colorify) val += "pointer"; else val += changeBarClass(d); return val; })
            .attr("id", function(d, i) { return "bar-under-" + ymdFormat(d["Date"]).replace(/-/g,""); })
            .attr("y", function(d) { var val = -h(maxApiValue); if (colorify) val -= incrCompact; return val;})
            .attr("title", function(d) {
                return ymdFormat(d["Date"]);
            })
            .attr("width", 3)
            .attr("height", function(d) { var val = h(maxApiValue); if (colorify) val += incrCompact; return val;});
        var bars = gBars.append("rect")
            .attr("class", function(d) { return "bar " + changeBarClass(d); })
            .attr("id", function(d, i) { return "bar-" + ymdFormat(d["Date"]).replace(/-/g,""); })
            .attr("y", function(d) { return -h(Math.min(maxApiValue,d[startStation + " Average"])); })
            .attr("title", function(d) {
                return ymdFormat(d["Date"]);
            })
            .attr("width", 3)
            .attr("height", function(d) { return h(Math.min(maxApiValue,d[startStation + " Average"])); })
            .attr("fill", changeFill);

        var mouseOverText = svg.append("text").text("").attr("class", "over-text api-value");
        var mouseOverDateText = svg.append("text").text("").attr("class", "over-text date");
        mouseOverDateText
        .on("mouseover", function(d) {
            clearInterval(cooldownBarsMouseOut);
        })
        .on("mouseout", barMouseOut);
        mouseOverText
        .on("mouseover", function(d) {
            clearInterval(cooldownBarsMouseOut);
        })
        .on("mouseout", barMouseOut);

        function changeBarClass (d, i) {
            if (d[currentStation + " Average"] > 200) classname = "severe";
            else if (d[currentStation + " Average"] > 100) classname = "veryhigh";
            else if (d[currentStation + " Average"] > 50) classname = "high";
            else if (d[currentStation + " Average"] > 25) classname = "medium";
            else if (d[currentStation + " Average"] > 0) classname = "low";
            else classname = "";
            return classname;
        }

        function changeFill (d, i) {
            if (!colorify) return "#000";
            if (d[currentStation + " Average"] > 200) fillColor = "#000";
            else if (d[currentStation + " Average"] > 100) fillColor = "#F33";
            else if (d[currentStation + " Average"] > 50) fillColor = "#FF3";
            else if (d[currentStation + " Average"] > 25) fillColor = "#3FF";
            else if (d[currentStation + " Average"] > 0) fillColor = "#393";
            else fillColor = "#999";
            return fillColor;
        }

        function changeAirPollutionData() {
            currentStation = menu.property("value");
            var stnobj = getStnObjFromName(currentStation);
            if (stnobj.characteristics.length > 0) d3.select("#station-desc").html(stnobj.characteristics);
            else d3.select("#station-desc").html("");
            if (sorted) {
                sortAirPollution (currentStation);
            }
            bars.transition().duration(normalDuration)
                .attr("class", "bar")
                .attr("y", function(d) { return -h(Math.min(maxApiValue,d[currentStation + " Average"]));})
                .attr("height", function(d) { return h(Math.min(maxApiValue,d[currentStation + " Average"]));})
                .attr("fill", changeFill);
            barsUnder
                .attr("class", function(d) { var val = "bar-under "; if (colorify) val += "pointer"; else val += changeBarClass(d); return val; })
                .attr("y", function(d) { var val = -h(maxApiValue); if (colorify) val -= incrCompact; return val;})
                .attr("height", function(d) { var val = h(maxApiValue); if (colorify) val += incrCompact; return val;});
            gBars.transition().duration(normalDuration)
                .attr("transform", function(d,i) {return "translate("+xfunc(d,i)+","+y(Number(d3.time.format("%Y")(d["Date"])))+")";})
            barMouseOver(airpollution[airpollution.length-1], i);
            yearLabels
                .transition().duration(normalDuration)
                .attr("y",function(d){return y(d);});
            if (colorify) {
                svg.attr("height", (maxYear - minYear + 1) * (maxApiValue + increment) * coefApiValue * coefCompact);
            } else {
                svg.attr("height", (maxYear - minYear + 1) * (maxApiValue + increment) * coefApiValue);
            }
        }
        function toggleColors() {
            if (colorify) {
                colorify = false;
                d3.select("#colouring").attr("class", d3.select("#colouring").attr("class").replace(/ selected/,""));
            } else {
                colorify = true;
                d3.select("#colouring").attr("class", d3.select("#colouring").attr("class") + " selected");
            }
            changeAirPollutionData();
        }
        function toggleSorting() {
            if (sorted) {
                sorted = false;
                d3.select("#sorting").attr("class", d3.select("#sorting").attr("class").replace(/ selected/,""));
            } else {
                sorted = true;
                d3.select("#sorting").attr("class", d3.select("#sorting").attr("class") + " selected");
            }
            changeAirPollutionData();
        }
        d3.select("#sorting").on("click", toggleSorting);
        d3.select("#colouring").on("click", toggleColors);

        /* Scales */
        var years = d3.range(minYear, maxYear);
        quantities = [];//[50, 100, 150];
        for (var i=0; i<quantities.length; i++) {
            var quantity = quantities[i];
            var groupScales = svg.append("g")
                .attr("class", "g-x g-scale");
            var scales = groupScales.selectAll("line.scales")
                .data(years)
            .enter()
            .append("line")
                .attr("x1",0)
                .attr("x2",width)
                .attr("y1", function(d){ return y(d) - quantity;})
                .attr("y2", function(d){ return y(d) - quantity;});
        }

        /* Weather data lines */
        var weatherTypes = [];
        //var weatherTypes = ["maxtemp", "mintemp", "rainfall", "winddir", "windspeed"];
        //var weatherTypes = ["winddir", "windspeed"];
        for (var i=0; i<weatherTypes.length; i++) {
            var coef = 2;
            if (weatherTypes[i] == "rainfall") coef = 0.5;
            else if (weatherTypes[i] == "winddir") coef = 0.25;
            else if (weatherTypes[i] == "windspeed") coef = 1;
            var line = d3.svg.line()
                .x(function(d) { return xfunc(d); })
                .y(function(d) { if(isNaN(d[weatherTypes[i]])) d[weatherTypes[i]] = 0; return y(Number(d3.time.format("%Y")(d.date))) - (d[weatherTypes[i]] * coef); });
            for (x in weatherByYear) {
                svg.append("path")
                    .data([weatherByYear[x]])
                    .attr("class", "line " + weatherTypes[i])
                    .attr("d", line);
            }
        }

        barMouseOver(airpollution[airpollution.length-1], i);
        d3.select("#loadingbar").style("display", "none");
    }
})();
