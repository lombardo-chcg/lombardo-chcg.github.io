document.addEventListener('DOMContentLoaded', () => {
  const toggleButton = document.getElementById('dark-mode-toggle');
  const body = document.body;
  
  // Update button text/icon based on current mode
  function updateButtonText() {
    if (body.classList.contains('dark-mode')) {
      toggleButton.innerHTML = '☀️'; // Sun icon for light mode
      toggleButton.setAttribute('aria-label', 'Switch to light mode');
    } else {
      toggleButton.innerHTML = '🌙'; // Moon icon for dark mode
      toggleButton.setAttribute('aria-label', 'Switch to dark mode');
    }
  }

  // Initial check is handled by inline script to avoid FOUC, 
  // but we need to update the button state here.
  updateButtonText();

  toggleButton.addEventListener('click', (e) => {
    e.preventDefault();
    body.classList.toggle('dark-mode');
    
    // Save preference
    if (body.classList.contains('dark-mode')) {
      localStorage.setItem('theme', 'dark');
    } else {
      localStorage.setItem('theme', 'light');
    }
    
    updateButtonText();
  });
});
