export const uniq = (array) => array.filter((x, i, self) => self.indexOf(x) === i);
