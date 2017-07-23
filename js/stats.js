(function() {

  init();

  function init() {
    var postCount,
        averagePostLength,
        mostCommonWords,
        mostCommonWordsSortedDesc,
        topTenWords

    // window.StatsStore is set in a script tag in about.html using Jekyll's built in iteration
    postCount = window.StatsStore.length;

    averagePostLength = Math.round(
      window.StatsStore
        .map(function(post) { return post.content.split(" ").length })
        .reduce(function(acc, cur) { return acc + cur })
      / window.StatsStore.length
    );

    mostCommonWords = window.StatsStore
      .map(normalizeTopWords)
      .reduce(wordMapReducer, {})

    mostCommonWordsSortedDesc = Object.keys(mostCommonWords)
      .map(function(key) {
        return [key, mostCommonWords[key]]
      })
      .sort(function(a, b) {
        return b[1] - a[1];
      });

    topTenWords = mostCommonWordsSortedDesc.slice(0, 9).map(function(result) {return result[0]});

    setContentByID("postCount", postCount)
    setContentByID("averagePostLength", averagePostLength)

    topTenWords.forEach(function(subject) {
      var node = '\n<li>\n<a href="/search?term=' + subject + '">' + subject + '</a>\n</li>\n';
      document.getElementById("mostCommonSubjects").innerHTML += node;
    })
  }

  function isValidWord(word) {
    return (
      word.length > 0
      && word !== ", "
      && word !== "the"
      && word !== "in"
      && word !== "(part"
      && word !== "+"
    );
  }

  function normalizeTopWords(post) {
    var title = post.title.split(" ")
    var tags = post.tags.replace(/[\[\]\"]/g, "").split(/&quot;/)

    return title.concat(tags).filter(isValidWord)
  }

  function wordMapReducer(wordMap, currentGrouping) {
    currentGrouping.forEach(function(word) {
      if (wordMap[word]) {
        wordMap[word] += 1;
      } else {
        wordMap[word] = 1;
      }
    });

    return wordMap;
  }

  function setContentByID(id, content) {
    document.getElementById(id).innerHTML = content;
  }
}());
