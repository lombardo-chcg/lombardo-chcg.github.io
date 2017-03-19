window.onload = function() {
  document.getElementById("search-box").focus();
  let params = new URLSearchParams(document.location.search.substring(1));

  console.log(params.get('term'))
  search(params.get('term'));
};

function setContentByID(id, content) {
  document.getElementById(id).innerHTML = content;
}

function clearSearchResults() {
  [
    'ux-feedback',
    'top-tier-results-header',
    'top-tier-results',
    'lower-tier-results-header',
    'lower-tier-results'
  ].forEach(divId => setContentByID(divId, ''))
}

function search(term) {
  clearSearchResults();
  var searchRequest;

  if (!term) {
    var searchRequest = document.getElementById('search-box').value.toLowerCase();
  }

  searchRequest = term;

  if (searchRequest.length === 0) {
    setContentByID('ux-feedback', '<p>must enter a search term</p>');
    return;
  }

  var searchResults = window.postsStore.reduce((results, post) => {
    if (post.categories.includes(searchRequest) || post.tags.includes(searchRequest) || post.excerpt.includes(searchRequest)) {
      results.topTier.push(post);
      return results;
    }

    if (post.content.includes(searchRequest)) {
      results.lowerTier.push(post);
      return results;
    }

    return results;
  }, { topTier: [], lowerTier: [] })

  if (!searchResults.topTier.length && !searchResults.lowerTier.length) {
    setContentByID('ux-feedback', '<p>no results found</p>');
    return;
  }

  displayResults('top-tier-results', searchResults.topTier);
  displayResults('lower-tier-results', searchResults.lowerTier);
}

function displayResults(sectionName, results) {
  if (results.length) {
    setContentByID(`${sectionName}-header`, sectionName.replace(/-/g, ' '));

    results.forEach(result => {
      var node = `
        <div>
          <a href="${result.url}">${result.title}</a>
          <h6><i>${result.excerpt}</i></h6>
        </div>
      `
      document.getElementById(sectionName).innerHTML += node;
    });
  }
}
