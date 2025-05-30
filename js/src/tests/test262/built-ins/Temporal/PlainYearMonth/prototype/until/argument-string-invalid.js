// |reftest| shell-option(--enable-temporal) skip-if(!this.hasOwnProperty('Temporal')||!xulRuntime.shell) -- Temporal is not enabled unconditionally, requires shell-options
// Copyright (C) 2022 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.

/*---
esid: sec-temporal.plainyearmonth.prototype.until
description: An invalid ISO string is never supported
includes: [temporalHelpers.js]
features: [Temporal]
---*/

const instance = new Temporal.PlainYearMonth(1976, 11);

for (const arg of TemporalHelpers.ISO.plainYearMonthStringsInvalid()) {
  assert.throws(RangeError, () => instance.until(arg), `"${arg}" is not a valid PlainYearMonth string`);
}

reportCompare(0, 0);
