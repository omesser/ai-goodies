---
name: analyze-stock-graph
description: Read a stock chart with Edwards & Magee structure and William O'Neil's buy rules.
disable-model-invocation: true
---

# Analyze Stock Graph

Read the chart the user gave you. Use Edwards & Magee for structure and patterns, and William O'Neil's buy rules.

The chart is the image or chart already in the conversation. If there is no chart, ask for one and stop.

Every price, ATR, and ratio comes from the chart or from a number the user supplied. If a figure is not there, mark that field unreadable.

## 1. Name the rules

Before the analysis, list the specific Edwards & Magee and O'Neil rules you will apply.

Done when every rule you will use is named, and the analysis that follows uses only rules from that list.

## 2. Give the read

- a verdict: buy, wait, or no trade
- the pattern, and a pivot or entry
- a stop, and how far it is in ATRs
- a target and the R:R
- the invalidation level

Done when all five are present and each one is tied to a rule from the list.
