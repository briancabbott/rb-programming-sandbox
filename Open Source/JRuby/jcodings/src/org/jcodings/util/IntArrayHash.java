/*
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package org.jcodings.util;

public final class IntArrayHash<V> extends Hash<V>{

    public IntArrayHash() {
        super();
    }

    public IntArrayHash(int size) {
        super(size);
    }

    protected void init() {
        head = new IntArrayHashEntry<V>();
    }

    public final static class IntArrayHashEntry<V> extends HashEntry<V> {
        public final int[]key;

        public IntArrayHashEntry(int hash, HashEntry<V> next, V value, int[]key, HashEntry<V> head) {
            super(hash, next, value, head);
            this.key = key;
        }

        public IntArrayHashEntry() {
            super();
            key = null;
        }

        public boolean equals(int[]key) {
            if (this.key == key) return true;
            if (this.key.length != key.length) return false;

            switch(key.length) {
            case 1: return this.key[0] == key[0];
            case 2: return this.key[0] == key[0] && this.key[1] == key[1];
            case 3: return this.key[0] == key[0] && this.key[1] == key[1] && this.key[2] == key[2];
            case 4: return this.key[0] == key[0] && this.key[1] == key[1] && this.key[2] == key[2] && this.key[3] == key[3];
            default: for (int i=0; i<key.length;i++) if (this.key[i] != key[i]) return false;
            }
            return true;
        }
    }

    private int hashCode(int[]key) {
        switch(key.length) {
        case 1: return key[0];
        case 2: return key[0] + key[1];
        case 3: return key[0] + key[1] + key[2];
        case 4: return key[0] + key[1] + key[2] + key[3];
        default:
            int h = 0;
            for (int i=0; i<key.length; i++) h += key[i];
            return h;
        }
    }

    public V put(int[]key, V value) {
        checkResize();
        int hash = hashValue(hashCode(key));
        int i = bucketIndex(hash, table.length);

        for (IntArrayHashEntry<V> entry = (IntArrayHashEntry<V>)table[i]; entry != null; entry = (IntArrayHashEntry<V>)entry.next) {
            if (entry.hash == hash && entry.equals(key)) {
                entry.value = value;
                return value;
            }
        }

        table[i] = new IntArrayHashEntry<V>(hash, table[i], value, key, head);
        size++;
        return null;
    }

    public void putDirect(int[]key, V value) {
        checkResize();
        final int hash = hashValue(hashCode(key));
        final int i = bucketIndex(hash, table.length);
        table[i] = new IntArrayHashEntry<V>(hash, table[i], value, key, head);
        size++;
    }


    public V get(int ... key) {
        int hash = hashValue(hashCode(key));
        for (IntArrayHashEntry<V> entry = (IntArrayHashEntry<V>)table[bucketIndex(hash, table.length)]; entry != null; entry = (IntArrayHashEntry<V>)entry.next) {
            if (entry.hash == hash && entry.equals(key)) return entry.value;
        }
        return null;
    }

    public V delete(int ... key) {
        int hash = hashValue(hashCode(key));
        int i = bucketIndex(hash, table.length);

        IntArrayHashEntry<V> entry = (IntArrayHashEntry<V>)table[i];

        if (entry == null) return null;

        if (entry.hash == hash && entry.equals(key)) {
            table[i] = entry.next;
            size--;
            entry.remove();
            return entry.value;
        }

        for (; entry.next != null; entry = (IntArrayHashEntry<V>)entry.next) {
            HashEntry<V> tmp = entry.next;
            if (tmp.hash == hash && entry.equals(key)) {
                entry.next = entry.next.next;
                size--;
                tmp.remove();
                return tmp.value;
            }
        }
        return null;
    }
}
