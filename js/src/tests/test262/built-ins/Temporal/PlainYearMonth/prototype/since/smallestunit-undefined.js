// |reftest| shell-option(--enable-temporal) skip-if(!this.hasOwnProperty('Temporal')||!xulRuntime.shell) -- Temporal is not enabled unconditionally, requires shell-options
// Copyright (C) 2021 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.

/*---
esid: sec-temporal.plainyearmonth.prototype.since
description: Fallback value for smallestUnit option
includes: [temporalHelpers.js]
features: [Temporal]
---*/

const earlier = new Temporal.PlainYearMonth(2000, 5);
const later = new Temporal.PlainYearMonth(2001, 6);

const explicit = later.since(earlier, { smallestUnit: undefined });
TemporalHelpers.assertDuration(explicit, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, "default smallestUnit is month");
const implicit = later.since(earlier, {});
TemporalHelpers.assertDuration(implicit, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, "default smallestUnit is month");

reportCompare(0, 0);
