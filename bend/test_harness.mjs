import assert from 'node:assert/strict';
import H from './harness.bend';

const empty = { $: 'Nil' };
const evidence = { $: 'Con', head: { $: 'Evidence', file: 'migrations.sql', symbol: '', revision: '' }, tail: empty };
const rule = (id, origin, status, ev = empty) => ({ $: 'Rule', id, description: `Rule ${id}`, origin, status, evidence: ev });
const harness = rules => ({ $: 'Harness', version: 1, project: 'demo', rules });
const list = xs => xs.reduceRight((tail, head) => ({ $: 'Con', head, tail }), empty);

assert.equal(H.valid(harness(empty)), true);
assert.equal(H.valid(harness(list([rule('ai', { $: 'AI' }, { $: 'Approved' }, evidence)]))), true);
assert.equal(H.valid(harness(list([rule('ai', { $: 'AI' }, { $: 'Approved' })]))), false);
assert.equal(H.valid(harness(list([rule('same', { $: 'Human' }, { $: 'Candidate' }), rule('same', { $: 'Human' }, { $: 'Candidate' })]))), false);
assert.equal(H.valid(harness(list([rule('', { $: 'Human' }, { $: 'Candidate' })]))), false);
assert.equal(H.valid({ $: 'Harness', version: 2, project: 'demo', rules: empty }), false);
assert.equal(H.transition_allowed({ $: 'Candidate' }, { $: 'Approved' }), true);
assert.equal(H.transition_allowed({ $: 'Approved' }, { $: 'Rejected' }), false);
assert.equal(H.transition_allowed({ $: 'Approved' }, { $: 'Candidate' }), true);
assert.equal(H.approved_rules(list([rule('a', { $: 'Human' }, { $: 'Approved' }), rule('b', { $: 'Human' }, { $: 'Candidate' }), rule('c', { $: 'Human' }, { $: 'Rejected' })])), 1n);
console.log('Harness IR: 10 assertions passed.');
