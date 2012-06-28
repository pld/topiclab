var fill = d3.scale.category20b();

var paletteJSON = jsonp().callback("jsonCallback");

paletteJSON("http://www.colourlovers.com/api/palettes/random", {},
        function(d) {
  fill.range(d[0].colors);
  vis.selectAll("text")
    .style("fill", function(d) { return fill(d.text.toLowerCase()); });
});

topics.map(function(topic) {
  var maxSize = 0;
  var minSize = 1000;

  var words = topic.map(function(word_size) {
    for (obj in word_size) { var word = obj; }
    var size = word_size[word];
    if (size > maxSize) { maxSize = size; }
    if (size < minSize) { minSize = size; }
    return {text: word, size: size};
  })

  var fontSize = d3.scale.log().range([10, 100]);
  fontSize.domain([minSize, maxSize]);

  var layout = d3.layout.cloud()
    .size([960, 600])
    .timeInterval(10)
    .font("Impact")
    .fontSize(function(d) { return fontSize(+d.size); })
    .rotate(function(d) { return ~~(Math.random() * 5) * 30 - 60; })
    .padding(1)
    .on("word", function(d) { console.log(+d.size); })
    .on("end", draw)
    .stop()
    .words(words)
    .start();

  function draw(words) {
    d3.select("body").append("svg")
        .attr("width", 960)
        .attr("height", 600)
      .append("g")
        .attr("transform", "translate(480, 300)")
      .selectAll("text")
        .data(words)
      .enter().append("text")
        .style("font-size", function(d) { return d.size + "px"; })
        .style("font-family", function(d) { return d.font; })
        .style("fill", function(d) { return fill(d.text.toLowerCase()); })
        .attr("text-anchor", "middle")
        .attr("transform", function(d) {
          return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
        })
        .text(function(d) { return d.text; });
  }
});
