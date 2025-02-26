// Scrolling feature implemented in project example

// scroll line into the middle of its respective subwindow
function reveal(line) {
    const element = document.getElementById(line);
    element.scrollIntoView({
      behavior: 'auto',
      block: 'center',
      inline: 'center'
    });
  }
  // green-highlight aline,
  // yellow-highlight all source lines that contributed to aline,
  // and scroll sline into view
  function aclick(aline, sline) {
    const srcLines = document.querySelectorAll("span[aline]");  // slines have an aline list
    const asmLines = document.querySelectorAll("span[sline]");  // alines have an sline list
    // clear all assembly lines
    asmLines.forEach((l) => {
      l.style.backgroundColor = 'white';
    })
    srcLines.forEach((sl) => {
      if (sl.matches("span[aline~="+aline+"]")) {
          sl.style.backgroundColor = 'yellow';
          asmLines.forEach((al) => {
            if (al.matches("span[sline~="+sl.id+"]")) {
              al.style.backgroundColor = 'PapayaWhip';
            }
          })
      } else {
          sl.style.backgroundColor = 'white';
      }
    })
    const l = document.getElementById(aline);
    l.style.backgroundColor = 'PaleGreen';
    reveal(sline);
  }
  // green-highlight sline,
  // yellow-highlight all assembly lines that correspond to sline,
  // and scroll aline into view
  function sclick(sline, aline) {
    const asmLines = document.querySelectorAll("span[sline]");  // alines have an sline list
    const srcLines = document.querySelectorAll("span[aline]");  // slines have an aline list
    // clear all source lines
    srcLines.forEach((l) => {
      l.style.backgroundColor = 'white';
    })
    asmLines.forEach((l) => {
      if (l.matches("span[sline~="+sline+"]")) {
          l.style.backgroundColor = 'yellow';
      } else {
          l.style.backgroundColor = 'white';
      }
    })
    const l = document.getElementById(sline);
    l.style.backgroundColor = 'PaleGreen';
    reveal(aline);
  }