// |reftest| shell-option(--enable-temporal) skip-if(!this.hasOwnProperty('Temporal')||!xulRuntime.shell) -- Temporal is not enabled unconditionally, requires shell-options
// Copyright (C) 2022 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.

/*---
esid: sec-temporal.plaindate.prototype.since
description: Leap second is a valid ISO string for PlainDate
includes: [temporalHelpers.js]
features: [Temporal]
---*/

const instance = new Temporal.PlainDate(2016, 12, 31);

let arg = "2016-12-31T23:59:60";
const result1 = instance.since(arg);
TemporalHelpers.assertDuration(
  result1,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  "leap second is a valid ISO string for PlainDate"
);

arg = { year: 2016, month: 12, day: 31, hour: 23, minute: 59, second: 60 };
const result2 = instance.since(arg);
TemporalHelpers.assertDuration(
  result2,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  "second: 60 is ignored in property bag for PlainDate"
);

reportCompare(0, 0);
