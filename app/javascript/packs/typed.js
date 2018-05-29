import Typed from 'typed.js';

function loadDynamicBannerText() {
  new Typed('#homeful-typed', {
    strings: ["Make meaningful donations", "Help others in need", "Stop food waste", "Volunteer to help"],
    typeSpeed: 80,
    loop: true
  });
}

loadDynamicBannerText();