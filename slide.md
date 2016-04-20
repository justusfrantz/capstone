Coursera Data Science Capstone: Course Project
========================================================
author: NG PENG HONG
date: Wed Apr 20 18:33:47 2016


![header](./www/headers.png)

Predict the Next Word

Introduction
========================================================
type: sub-section
<span style="color:blue; font-weight:bold; font-size:0.7em">This presentation is created as part of the requirement for the Coursera Data Science Capstone Course. </span>

<font size="5">
The goal of the project is to build a predictive text model combined with a shiny app UI that will predict the next word as the user types a sentence similar to the way most smart phone keyboards are implemented today using the technology of Swiftkey.

*[Shiny App]* - [https://phng.shinyapps.io/capstone]

*[Github Repo]* - [https://github.com/justusfrantz/capstone]

</font>

Getting & Cleaning the Data
========================================================
type: sub-section

<span style="color:blue; font-weight:bold; font-size:0.7em">Before building the word prediction algorithm, data are first processed and cleaned as steps below:</span>

<font size="5">

- A subset of the original data was sampled from the three sources (blogs,twitter and news) which is then merged into one.
- Next, data cleaning is done by conversion to lowercase, strip white space, and removing punctuation and numbers.
- The corresponding n-grams are then created (Quadgram,Trigram and Bigram).
- Next, the term-count tables are extracted from the N-Grams and sorted according to the frequency in descending order.
- Lastly, the n-gram objects are saved as R-Compressed files (.RData files).

</font>



Word Prediction Model
========================================================
type: sub-section

<span style="color:blue; font-weight:bold;font-size:0.7em">The prediction model for next word is based on the Katz Back-off algorithm. Explanation of the next word prediction flow is as below:</span>

<font size="5">

- Compressed data sets containing descending frequency sorted n-grams are first loaded.
- User input words are cleaned in the similar way as before prior to prediction of the next word.
- For prediction of the next word, Quadgram is first used (first three words of Quadgram are the last three words of the user provided sentence).
- If no Quadgram is found, back off to Trigram (first two words of Trigram are the last two words of the sentence).
- If no Trigram is found, back off to Bigram (first word of Bigram is the last word of the sentence)
- If no Bigram is found, back off to the most common word with highest frequency 'the' is returned.

</font>

Shiny Application
========================================================
type: sub-section

<span style="color:blue; font-weight:bold;font-size:0.7em">A Shiny application was developed based on the next word prediction model described previously as shown below. </span><img src="./www/app.png"></img>
