window.addEventListener("message", function (event) {
  const data = event.data;

  if (data.pedInVeh && !data.pauseMenuOn) {
    $(".container").css("display", "block");
    $(".container").stop(true, false);
    $(".container").animate({ opacity: "1" }, 150);

    $(".current-speed-value").text(data.speed);
    $(".current-gear-value").text(data.gear);
    $(".current-fuel").css("width", data.fuel + "%");
    $(".current-fuel-text").text(data.fuel + "%");

    $(".compass-street-name").text(data.streetName);
    $(".compass-zone-name").text(data.zoneName);
    $(".compass-direction").text(data.direction);

    if (data.speed >= data.speedLimit) {
      $(".current-speed-value").css({
        color: "rgba(184, 20, 20, 1)",
        "text-shadow": "0 0 3px rgba(184, 20, 20, 1)",
      });
    } else {
      $(".current-speed-value").css({
        color: "#fff",
        "text-shadow": "0 0 3px #fff",
      });
    }

    if (data.speed == 0 && data.gear >= 0) {
      $(".current-gear-value").text("N");
    }

    if (data.speed > 0 && data.gear == 0) {
      $(".current-gear-value").text("R");
    }

    if (data.speedType == "kmh") {
      $(".current-speed-text").text("KM/H");
    } else if (data.speedType == "mph") {
      $(".current-speed-text").text("M/H");
    }

    if (data.fuel <= data.fuelLimit) {
      $(".current-fuel-alert").addClass("blink-anim");
      $(".current-fuel-alert").css("display", "block");
      $(".current-fuel").css("box-shadow", "0 0 0 0 #000");
    } else {
      $(".current-fuel-alert").removeClass("blink-anim");
      $(".current-fuel-alert").css("display", "none");
      $(".current-fuel").css("box-shadow", "0 0 4px rgba(255, 193, 0, 1)");
    }
    if (data.signalLights === 0) {
      $(".left-signal").css("fill", "#fff");
      $(".right-signal").css("fill", "#fff");
      $(".hazard-light").css("fill", "#fff");
      $(".left-signal").removeClass("blink-anim");
      $(".right-signal").removeClass("blink-anim");
      $(".hazard-light").removeClass("blink-anim");
    } else if (data.signalLights === 1) {
      $(".left-signal").css("fill", "lime");
      $(".left-signal").addClass("blink-anim");

      $(".right-signal").css("fill", "#fff");
      $(".hazard-light").css("fill", "#fff");
      $(".right-signal").removeClass("blink-anim");
      $(".hazard-light").removeClass("blink-anim");
    } else if (data.signalLights === 2) {
      $(".right-signal").css("fill", "lime");
      $(".right-signal").addClass("blink-anim");

      $(".left-signal").css("fill", "#fff");
      $(".hazard-light").css("fill", "#fff");
      $(".left-signal").removeClass("blink-anim");
      $(".hazard-light").removeClass("blink-anim");
    } else if (data.signalLights === 3) {
      $(".left-signal").css("fill", "lime");
      $(".right-signal").css("fill", "lime");
      $(".hazard-light").css("fill", "rgba(255, 193, 0, 1)");
      $(".left-signal").addClass("blink-anim");
      $(".right-signal").addClass("blink-anim");
      $(".hazard-light").addClass("blink-anim");
    }

    if (data.lights == "normal") {
      $(".low-beam").css("fill", "lime");
      $(".high-beam").css("fill", "#fff");

      $(".high-beam").hide();
      $(".low-beam").show();
    } else if (data.lights == "high") {
      $(".low-beam").css("fill", "lime");
      $(".high-beam").css("fill", "blue");

      $(".low-beam").hide();
      $(".high-beam").show();
    } else {
      $(".high-beam").hide();
      $(".low-beam").show();

      $(".low-beam").css("fill", "#fff");
      $(".high-beam").css("fill", "#fff");
    }

    if (data.engineControl) {
      $(".engine-control").css("fill", "lime");
    } else {
      $(".engine-control").css("fill", "rgba(184, 20, 20, 1)");
    }

    if (data.handbrake) {
      $(".handbrake-control").css("fill", "rgba(184, 20, 20, 1)");
    } else {
      $(".handbrake-control").css("fill", "#fff");
    }

    if (data.cruiseIsOn) {
      $(".cruise-control").css("fill", "lime");
    } else {
      $(".cruise-control").css("fill", "rgba(184, 20, 20, 1)");
    }

    if (data.isCar) {
      $(".seatbelt-control").css("display", "block");
      if (data.SeatbeltON) {
        $(".seatbelt-control").css("fill", "lime");
        $(".seatbelt-control").removeClass("blink-anim");
      } else {
        $(".seatbelt-control").css("fill", "rgba(184, 20, 20, 1)");
        $(".seatbelt-control").addClass("blink-anim");
      }
    } else {
      $(".seatbelt-control").css("display", "none");
    }
  } else {
    $(".container").animate({ opacity: "0" }, 150, () => {
      $(".container").css("display", "none");
    });
  }
});
