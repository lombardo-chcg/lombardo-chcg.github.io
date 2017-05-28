---
layout: post
title:  "postgres performance"
date:   2017-05-27 21:50:15
categories: databases
excerpt: "comparing indexed vs. non-indexed table query speed"
tags:
  - postgres
  - sql
---

I've always heard that databases with proper indexing can perform much faster than non-indexed versions.  So I decided to set up a little test to check this out.

I created an indexed and non-indexed version of my [Scrabble Helper Postgres DB](https://github.com/lombardo-chcg/postgres-scrabble-helper)

`docker pull lombardo/postgres-scrabble-helper:0.1` => non-indexed


`docker pull lombardo/postgres-scrabble-helper:1.0` => indexed

The syntax for adding an index to a Postgres table is easy:

{% highlight sql %}
-- CREATE INDEX <index_name> ON <table_name> (<column_name>)
CREATE INDEX canonical_word_index ON words (canonical_word);
{% endhighlight %}

Postgres uses the [B-tree](https://en.wikipedia.org/wiki/B-tree) index method by default, and that is fine for our purposes.

I wired up both versions of the SQL database to my [Scrabble Helper API](https://github.com/lombardo-chcg/scrabble-helper-api) and here's a comparison of performance.

The `**` in the query indicates 2 wildcards (aka the blank Scrabble tiles)

| **Query** | **Number of queries** | **Non-Indexed DB** | **Indexed DB** |
| `GET /words/testing` | 72  | 1307 ms | 115 ms |
| `GET /words/testing**` | 23,986  | 415855 ms (~7 minutes) | 10548 ms (10.5 seconds) |
| `GET /words/indexxedni` | 216  | 3680 ms | 166 ms |
| `GET /words/indexxedni**` | 65,925  | 1155465 ms (~19 minutes) | 26597 ms (26.6 seconds)|


--


Needless to say these results speak for themselves...

<style>
table {
    border-collapse: collapse;
    border-spacing: 0;
    border:2px solid #000000;
}

th {
    border:2px solid #000000;
    padding: 5px;
}

td {
    border:1px solid #000000;
    padding: 5px;
    font-size: 14px;
}
</style>
