export function stub() {}

export function new_node() {
  return [];
}

export function new_node_2(a, b) {
  return [a, b];
}

export function element(i, n) {
  return n[i - 1];
}

export function set_element(i, n, v) {
  const a = n.slice(0);
  a[i - 1] = v;
  return a;
}

export function append_element(n, v) {
  const l = n.length;
  const a = new Array(l + 1);
  for (let i = 0; i < l; i++) {
    a[i] = n[i];
  }
  a[l] = v;
  return a;
}

export function delete_element(i, n) {
  const l = i - 1;
  const a = new Array(l);
  for (let i = 0; i < l; i++) {
    a[i] = n[i];
  }
  return a;
}

export function size(n) {
  return n.length;
}
