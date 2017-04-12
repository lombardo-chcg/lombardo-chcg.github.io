---
layout: post
title:  "file i-o in scala"
date:   2017-04-12 16:42:58
categories: languages
excerpt: "reading and writing to the file system in scala"
tags:
  - scala
---

As part of my [Scala-Docker-Postgres project](/search?term=scalatra) I wanted to do something a little more useful than the "Hello World on steroids" app I have done so far.

I thought it might be fun to make a Scrabble-style dictionary, where the user inputs any combination of characters and the application returns a list of valid English words that can be constructed from those letters.

For that, I decided to make a CSV file that I can import into Postgres containing the columns `word` and `canonical_word`

So for a row here's how it would look:
{% highlight bash %}

ID |   word     |  canonical_word
---------------------------------
1  |  aardvark  |    aaadkrrv

{% endhighlight %}

The idea is when a user submits any collection of characters, we just alphabetize the collection and search against a list of all alphabetized or "canonical words" and return the English equivalents.

Since Scala runs on the JVM we have access to the famous `java.io` library which makes parsing the list a piece of cake.

here's the list of words I'm using:
[https://github.com/dwyl/english-words/blob/master/words.txt](https://github.com/dwyl/english-words/blob/master/words.txt)

{% highlight bash %}
url="https://raw.githubusercontent.com/dwyl/english-words/master/words.txt"

curl $url >> words.txt

touch WordMapper.scala
{% endhighlight %}

in `WordMapper.scala`:
{% highlight scala %}
import java.io._
import scala.io.Source

val inputFile = "words.txt"
val outputFile = new File("dict.csv")
val fileWriter = new BufferedWriter(new FileWriter(outputFile))

for (word <- Source.fromFile(inputFile).getLines) {
  val canonical = word.split("").sorted.mkString("")
  fileWriter.write(s"""$word, $canonical\n""")
}

fileWriter.close
{% endhighlight %}

Back in the bash terminal:
{% highlight bash %}
scala WordMapper.scala

tail dict.csv

# zymotic, cimotyz
# zymotically, acillmotyyz
# zymotize, eimotyzz
# zymotoxic, cimootxyz
# zymurgies, egimrsuyz
# zymurgy, gmruyyz
# zythem, ehmtyz
# zythum, hmtuyz
# zyzzyva, avyyzzz
# zyzzyvas, asvyyzz
{% endhighlight %}

Nice and easy.  Now we have a file ready to import into Postgres.
