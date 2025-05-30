// |reftest| shell-option(--enable-iterator-helpers) skip-if(!this.hasOwnProperty('Iterator')||!xulRuntime.shell) -- iterator-helpers is not enabled unconditionally, requires shell-options
// Copyright (C) 2024 Mozilla Corporation. All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.

/*---
includes: [sm/non262-shell.js, sm/non262.js]
flags:
- noStrict
features:
- iterator-helpers
info: |
  Iterator is not enabled unconditionally
description: |
  pending
esid: pending
---*/
const iter = (value) => Iterator.from({
  next: () => value,
});

for (let value of [
  undefined,
  null,
  0,
  false,
  "test",
  Symbol(""),
]) {
  assert.sameValue(iter(value).next(), value);
}


reportCompare(0, 0);
