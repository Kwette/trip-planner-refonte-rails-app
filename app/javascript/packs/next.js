const next = () => {
  const buttonOne = document.getElementById('buttonOne');
  const buttonTwo = document.getElementById('buttonTwo');

  buttonTwo.addEventListener('click', (event) => {
    step3 = document.getElementById('step3');
    console.log(step3)
    step3.scrollIntoView({behavior: "smooth"});
  });
}

next();
