$(() => {
  window.addEventListener('message', (e) => {
    const data = e.data;

    if (!data.pauseMenuOn) {
      switch (data.action) {
        case 'ui':
          if (data.ui) {
            $('.container').show();

            $('.current-speed-value').text(data.speed);
            $('.current-gear-value').text(data.gear);
            $('.current-fuel').css('width', data.fuel + '%');
            $('.current-fuel-text').text(data.fuel + '%');

            if (data.speed >= data.speedLimit) {
              $('.current-speed-value').css({
                color: 'rgba(184, 20, 20, 1)',
                'text-shadow': '0 0 3px rgba(184, 20, 20, 1)',
              });
            } else {
              $('.current-speed-value').css({
                color: '#fff',
                'text-shadow': '0 0 3px #fff',
              });
            }

            if (data.speedType == 'kmh') {
              $('.current-speed-text').text('KM/H');
            } else if (data.speedType == 'mph') {
              $('.current-speed-text').text('MPH');
            }

            if (data.speed == 0 && data.gear >= 0) {
              $('.current-gear-value').text('N');
            }

            if (data.speed > 0 && data.gear == 0) {
              $('.current-gear-value').text('R');
            }

            if (data.fuel <= data.fuelLimit) {
              $('.current-fuel-alert').addClass('blink-anim');
              $('.current-fuel-alert').css('display', 'block');
              $('.current-fuel').css('box-shadow', '0 0 0 0 #000');
            } else {
              $('.current-fuel-alert').removeClass('blink-anim');
              $('.current-fuel-alert').css('display', 'none');
              $('.current-fuel').css('box-shadow', '0 0 4px rgba(236, 178, 3, 1)');
            }

            if (data.indicator === 0) {
              $('.left-signal').css('fill', '#fff');
              $('.right-signal').css('fill', '#fff');
              $('.hazard-light').css('fill', '#fff');
              $('.left-signal').removeClass('blink-anim');
              $('.right-signal').removeClass('blink-anim');
              $('.hazard-light').removeClass('blink-anim');
            } else if (data.indicator === 1) {
              $('.left-signal').css('fill', 'limegreen');
              $('.left-signal').addClass('blink-anim');

              $('.right-signal').css('fill', '#fff');
              $('.hazard-light').css('fill', '#fff');
              $('.right-signal').removeClass('blink-anim');
              $('.hazard-light').removeClass('blink-anim');
            } else if (data.indicator === 2) {
              $('.right-signal').css('fill', 'limegreen');
              $('.right-signal').addClass('blink-anim');

              $('.left-signal').css('fill', '#fff');
              $('.hazard-light').css('fill', '#fff');
              $('.left-signal').removeClass('blink-anim');
              $('.hazard-light').removeClass('blink-anim');
            } else if (data.indicator === 3) {
              $('.left-signal').css('fill', 'limegreen');
              $('.right-signal').css('fill', 'limegreen');
              $('.hazard-light').css('fill', 'rgba(236, 178, 3, 1)');
              $('.left-signal').addClass('blink-anim');
              $('.right-signal').addClass('blink-anim');
              $('.hazard-light').addClass('blink-anim');
            }

            if (data.lights == 'normal') {
              $('.low-beam').css('fill', 'limegreen');
              $('.high-beam').css('fill', '#fff');

              $('.high-beam').hide();
              $('.low-beam').show();
            } else if (data.lights == 'high') {
              $('.low-beam').css('fill', 'limegreen');
              $('.high-beam').css('fill', '#272bff');

              $('.low-beam').hide();
              $('.high-beam').show();
            } else {
              $('.high-beam').hide();
              $('.low-beam').show();

              $('.low-beam').css('fill', '#fff');
              $('.high-beam').css('fill', '#fff');
            }

            if (data.engineControl) {
              $('.engine-control').css('fill', 'limegreen');
            } else {
              $('.engine-control').css('fill', 'rgba(184, 20, 20, 1)');
            }

            if (data.handbrake) {
              $('.handbrake-control').css('fill', 'rgba(184, 20, 20, 1)');
            } else {
              $('.handbrake-control').css('fill', '#fff');
            }

            if (data.isBigMap) {
              $('.wrapper').css('left', '24.7%');
            } else {
              $('.wrapper').css('left', '15.8%');
            }
          } else {
            $('.container').hide();
          }
          break;

        case 'compass':
          $('.compass-street-name').text(data.streetName);
          $('.compass-zone-name').text(data.zoneName);
          $('.compass-direction').text(data.direction);
          break;

        case 'cruise':
          if (data.cruiseIsOn) {
            $('.cruise-control').css('fill', 'limegreen');
          } else {
            $('.cruise-control').css('fill', 'rgba(184, 20, 20, 1)');
          }
          break;

        case 'seatbelt':
          if (data.isCar) {
            $('.seatbelt-control').css('display', 'block');
            if (data.SeatbeltON) {
              $('.seatbelt-control').css('fill', 'limegreen');
              $('.seatbelt-control').removeClass('blink-anim');
            } else {
              $('.seatbelt-control').css('fill', 'rgba(184, 20, 20, 1)');
              $('.seatbelt-control').addClass('blink-anim');
            }
          } else {
            $('.seatbelt-control').css('display', 'none');
          }
          break;
      }
    }
  });
});
