---
layout: post
title:  "exact change challenge"
date:   2017-03-04 21:44:19
categories: code-challenge
excerpt: making change in javascript
tags:
  - code-challenge
  - javascript
---

Today I tackled the [Exact Change Challenge](https://www.freecodecamp.com/challenges/exact-change) from Free Code Camp.  Some work friends and I discussed this problem over lunch a few days ago and I was eager to get my hands on it.

This solution is my preliminary version.  It technically makes all the tests go green, but it is very bulky and has a lot of nesting.  My goal is to refactor this in a more declarative, functional style.

I learned some interesting stuff in the process, for example, the native `Number.prototype.toFixed()` method in JavaScipt is used to convert a number to a decimal using fixed-point notation.  Example use:
{% highlight javascript %}
5.8484.toFixed(2)
//=> "5.85"
{% endhighlight %}
However it *returns a string* instead of an actual number.  So then `parseFloat` has to be called on the result.

Oh, silly JavaScript.  

But for now here's today's post: a solution to the [Exact Change Challenge](https://www.freecodecamp.com/challenges/exact-change).
{% highlight javascript %}
var changeMap = {
  'ONE HUNDRED': 100.00,
  'TWENTY': 20.00,
  'TEN': 10.00,
  'FIVE': 5.00,
  'ONE': 1.00,
  'QUARTER': 0.25,
  'DIME': 0.10,
  'NICKEL': 0.05,
  'PENNY': 0.01
};

function getDrawTotal(drawerArray) {
  return drawerArray.reduce((acc, cur) => {
    return acc + cur[1];
  }, 0);
}

function moneyify(number) {
  return parseFloat(number.toFixed(2));
}

function checkCashRegister(price, cash, cid) {
  var change = [];
  var changeDue = moneyify(cash - price);
  var drawTotal = moneyify(getDrawTotal(cid));

  if (drawTotal < changeDue) {
    return 'Insufficient Funds';
  }

  if (drawTotal === changeDue) {
    return 'Closed';
  }

  var changeDrawer = cid.reverse();

  // refactor goal: use a reduce function here instead
  changeDrawer.forEach(denom => {
    denomName = denom[0];
    denomValue = changeMap[denom[0]];
    denomStartingAmount = denom[1];

    if (changeDue >= denomValue && denomStartingAmount > 0) {
      var unitsInDrawer = denomStartingAmount / denomValue;
      var denomWithdrawl = [denomName, 0.00];

      while (unitsInDrawer && changeDue && denomValue <= changeDue) {
        denomWithdrawl[1] += denomValue;
        unitsInDrawer -= 1;
        changeDue = moneyify(changeDue - denomValue);
      }

      change.push(denomWithdrawl);
    }
  });

  var result = change.filter(denom => denom[1] > 0.00);

  if (moneyify(getDrawTotal(result)) !== moneyify(cash - price)) {
    return 'Insufficient Funds';
  }

  return result;
}

var solution = checkCashRegister(3.26, 100.00, [["PENNY", 1.01], ["NICKEL", 2.05], ["DIME", 3.10], ["QUARTER", 4.25], ["ONE", 90.00], ["FIVE", 55.00], ["TEN", 20.00], ["TWENTY", 60.00], ["ONE HUNDRED", 100.00]])

console.log(solution)
//=> [ [ 'TWENTY', 60 ],
//=>   [ 'TEN', 20 ],
//=>   [ 'FIVE', 15 ],
//=>   [ 'ONE', 1 ],
//=>   [ 'QUARTER', 0.5 ],
//=>   [ 'DIME', 0.2 ],
//=>   [ 'PENNY', 0.04 ] ]
{% endhighlight %}
