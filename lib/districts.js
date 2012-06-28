for(var i = 0; i < districts.length; i++) {
  var topic = [];
  var max = 0;

  for (district in districts[i]) {
    var size = districts[i][district];
    if (size > max) { max = size; }
    topic.push({text: district, size: size});
  }

  var width = 210
  var height = 10 * topic.length

  var x = d3.scale.linear().domain([0, max]).range([0, width]);
  var y = d3.scale.ordinal().domain(topic).rangeBands([0, 120]);

  // add the canvas to the DOM
  var chart = d3.select("body")
    .append("svg")
    .attr("class", "chart")
    .attr("width", width + 50)
    .attr("height", height);

  chart.selectAll("rect")
    .data(topic)
    .enter()
    .append("rect")
      .attr("y", function(d, i) { return i * 10; })
      .attr("width", function(d) { return x(d.size); })
      .attr("height", 10);

  chart.selectAll("text")
      .data(topic)
    .enter().append("text")
      .attr("x", function(d) { return x(d.size); })
      .attr("y", function(d, i) { return i * 10; })
      .attr("dx", 3) // padding-right
      .attr("dy", ".8em") // vertical-align: middle
      .attr("text-anchor", "start") // text-align: right
      .text(function(d) { return d.text; });
}
