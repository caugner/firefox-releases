/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

const CONFIG_V2 = [
  {
    recordType: "engine",
    identifier: "basic",
    base: {
      name: "basic",
      urls: {
        search: {
          base: "https://example.com",
          searchTermParamName: "q",
        },
        trending: {
          base: "https://example.com/browser/browser/components/search/test/browser/trendingSuggestionEngine.sjs",
          method: "GET",
          params: [
            {
              name: "richsuggestions",
              value: "true",
            },
          ],
        },
        suggestions: {
          base: "https://example.com/browser/browser/components/search/test/browser/trendingSuggestionEngine.sjs",
          method: "GET",
          params: [
            {
              name: "richsuggestions",
              value: "true",
            },
          ],
          searchTermParamName: "query",
        },
      },
      aliases: ["basic"],
    },
    variants: [
      {
        environment: { allRegionsAndLocales: true },
      },
    ],
  },
  {
    recordType: "defaultEngines",
    globalDefault: "basic",
    specificDefaults: [],
  },
  {
    recordType: "engineOrders",
    orders: [],
  },
];

SearchTestUtils.init(this);

add_setup(async () => {
  await SpecialPowers.pushPrefEnv({
    set: [
      ["browser.urlbar.recentsearches.featureGate", false],
      ["browser.urlbar.suggest.searches", true],
      ["browser.urlbar.trending.featureGate", true],
      ["browser.urlbar.trending.requireSearchMode", false],
    ],
  });

  await SearchTestUtils.updateRemoteSettingsConfig(CONFIG_V2);
});

add_task(async function test_trending_results() {
  await check_results({ featureEnabled: true });
  await check_results({ featureEnabled: false });
});

async function check_results({ featureEnabled = false }) {
  await SpecialPowers.pushPrefEnv({
    set: [["browser.urlbar.richSuggestions.featureGate", featureEnabled]],
  });

  await UrlbarTestUtils.promiseAutocompleteResultPopup({
    window,
    value: "",
    waitForFocus: SimpleTest.waitForFocus,
  });

  let numResults = UrlbarTestUtils.getResultCount(window);

  for (let i = 0; i < numResults; i++) {
    let { result } = await UrlbarTestUtils.getDetailsOfResultAt(window, i);
    Assert.equal(result.type, UrlbarUtils.RESULT_TYPE.SEARCH);
    Assert.equal(result.providerName, "SearchSuggestions");
    Assert.equal(result.payload.engine, "basic");
    Assert.equal(result.isRichSuggestion, featureEnabled);
    if (featureEnabled) {
      Assert.equal(typeof result.payload.description, "string");
      Assert.ok(result.payload.icon.startsWith("data:"));
    }
  }

  await SpecialPowers.popPrefEnv();
}

add_task(async function test_richsuggestion_deduplication() {
  await SpecialPowers.pushPrefEnv({
    set: [["browser.urlbar.richSuggestions.featureGate", true]],
  });

  await UrlbarTestUtils.promiseAutocompleteResultPopup({
    window,
    value: "test0",
    waitForFocus: SimpleTest.waitForFocus,
  });

  let { result: heuristicResult } = await UrlbarTestUtils.getDetailsOfResultAt(
    window,
    0
  );
  let { result: richResult } = await UrlbarTestUtils.getDetailsOfResultAt(
    window,
    1
  );

  // The Rich Suggestion that points to the same query as the Hueristic result
  // should not be deduplicated.
  Assert.equal(heuristicResult.type, UrlbarUtils.RESULT_TYPE.SEARCH);
  Assert.equal(heuristicResult.providerName, "HeuristicFallback");
  Assert.equal(richResult.type, UrlbarUtils.RESULT_TYPE.SEARCH);
  Assert.equal(richResult.providerName, "SearchSuggestions");
  Assert.equal(
    heuristicResult.payload.query,
    richResult.payload.lowerCaseSuggestion
  );

  await UrlbarTestUtils.promisePopupClose(window);
});
