// Determine if the dark style is active
var isDark = document.documentElement.classList.contains('dark-style');

// Select all elements that need the ripple effect
var elements = document.querySelectorAll('.btn:not(.disable-wave), .page-link:not(.disable-wave), .menu-link:not(.disable-wave), .dropdown-menu a:not(.disable-wave),  .nav-link:not(.disable-wave), .wave:not(.disable-wave)');

elements.forEach(function (element) {
    element.addEventListener('mousedown', createRipple);
    element.style.overflow = 'hidden';
    element.style.position = 'relative';
});

function createRipple(e) {
    var waveClass = !isDark ? 'wave-ripple' : 'wave-ripple-light';
    var children = this.getElementsByClassName(waveClass);

    // Remove existing ripple elements
    while (children.length > 0) {
        children[0].parentNode.removeChild(children[0]);
    }

    // Create and style new ripple element
    var circle = document.createElement('div');
    circle.style.position = 'absolute';
    this.appendChild(circle);

    var d = Math.max(this.clientWidth, this.clientHeight);
    var eRect = this.getBoundingClientRect();

    circle.style.width = circle.style.height = d + 'px';
    circle.style.left = e.clientX - eRect.left - d / 2 + 'px';
    circle.style.top = e.clientY - eRect.top - d / 2 + 'px';
    circle.classList.add(waveClass);

    // Remove the ripple element after some time
    setTimeout(function () {
        circle.remove();
    }, 1000);
}