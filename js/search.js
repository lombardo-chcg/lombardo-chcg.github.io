(function() {
  'use strict';

  // String.prototype.includes() Polyfill
  if (!String.prototype.includes) {
    String.prototype.includes = function(search) {
      return this.indexOf(search) !== -1;
    };
  }

  init();

  function init() {
    document.getElementById("search-box").focus();
    // extract the query params which lie after ?term=
    var params = document.location.search.substring(6);
    search(params);
  }

  function setContentByID(id, content) {
    document.getElementById(id).innerHTML = content;
  }

  function clearPageContent() {
    [
      'ux-feedback',
      'top-tier-results-header',
      'top-tier-results',
      'lower-tier-results-header',
      'lower-tier-results'
    ].forEach(function(divId) {
      return setContentByID(divId, '');
    });
  }

  function search(term) {
    var searchRequest, searchResults;

    clearPageContent();

    if (!term) {
      window.location.href = '/';
      return;
    }

    // temporary workaround for multi-word searches
    if (term.includes('%20')) {
      term = term.split('%20')[0];
    }

    searchRequest = term.toLowerCase();

    searchResults = searchPostStore(searchRequest);

    if (!searchResults.topTier.length && !searchResults.lowerTier.length) {
      setContentByID('ux-feedback', '<p>no results found</p>');
      return;
    }

    setContentByID('ux-feedback', '<h4>"<i>' + searchRequest + '</i>"</h4>');
    displayResults('top-tier-results', searchResults.topTier);
    displayResults('lower-tier-results', searchResults.lowerTier);
  }

  function searchPostStore(searchRequest) {
    // window.postsStore is set in a script tag in search.html using Jekyll's built in iteration
    return window.postsStore.reduce(function(results, post) {
      if (
        post.categories.includes(searchRequest)
        || post.tags.includes(searchRequest)
        || post.title.includes(searchRequest)
        || post.excerpt.includes(searchRequest)
      ) {
        results.topTier.push(post);
        return results;
      }

      if (post.content.includes(searchRequest)) {
        results.lowerTier.push(post);
        return results;
      }

      return results;
    }, { topTier: [], lowerTier: [] });
  }

  function displayResults(sectionName, results) {
    if (results.length) {
      setContentByID(sectionName + '-header', sectionName.replace(/-/g, ' ') + ' (' + results.length + ')');

      results.forEach(function(result) {
        var node = '\n        <div>\n          <a href="' + result.url + '">' + result.title + '</a>\n          <h6><i>' + result.excerpt + '</i></h6>\n        </div>\n      ';
        document.getElementById(sectionName).innerHTML += node;
      });
    }
  }
}());
