$(function () {
  window.addEventListener("message", function (event) {
    let data = event.data;
    $(".seatbelt").addClass("blink-anim");

    if (data.InVehicle) {
      $(".container").css("display", "block");
      $(".wrapper").show("fast");
      $(".current-speed-value").html(Math.round(data.speed));
      $(".current-gear-value").html(Math.round(data.gear));
      $(".current-fuel").css("width", data.fuel + "%");

      if (data.speed >= data.speedLimit) {
        $(".current-speed-value").css("color", "rgba(184, 20, 20, 1)");
        $(".current-speed-value").css(
          "text-shadow",
          "0 0 3px rgba(184, 20, 20, 1)"
        );
      } else {
        $(".current-speed-value").css("color", "#fff");
        $(".current-speed-value").css("text-shadow", "0 0 3px #fff");
      }

      if (data.speed == 0 && data.gear >= 0) {
        $(".current-gear-value").html("N");
      }

      if (data.speed > 0 && data.gear == 0) {
        $(".current-gear-value").html("R");
      }

      if (data.fuel <= data.fuelLimit) {
        $(".current-fuel-alert").css("display", "block");
        $(".current-fuel-alert").addClass("blink-anim");
        $(".current-fuel").css("box-shadow", "0 0 0 0 #000");
        $(".current-fuel-alert").css("background", "rgba(184, 20, 20, 1)");
        $(".current-fuel-alert").css(
          "box-shadow",
          "0px 0px 4px rgba(184, 20, 20, 1)"
        );
      } else {
        $(".current-fuel-alert").css("display", "none");
        $(".current-fuel-alert").removeClass("blink-anim");
        $(".current-fuel").css("box-shadow", "0 0 4px rgba(210, 172, 67, 1)");
      }

      if (data.signalLights == 1) {
        $(".left-signal").css("fill", "lime");
        $(".left-signal").addClass("blink-anim");
        $(".right-signal").css("fill", "#fff");
        $(".hazard-light").css("fill", "#fff");
        $(".right-signal").removeClass("blink-anim");
        $(".hazard-light").removeClass("blink-anim");
      } else if (data.signalLights == 2) {
        $(".right-signal").css("fill", "lime");
        $(".right-signal").addClass("blink-anim");
        $(".left-signal").css("fill", "#fff");
        $(".left-signal").removeClass("blink-anim");
        $(".hazard-light").css("fill", "#fff");
        $(".hazard-light").removeClass("blink-anim");
      } else if (data.signalLights == 3) {
        $(".left-signal").css("fill", "lime");
        $(".left-signal").addClass("blink-anim");
        $(".right-signal").css("fill", "lime");
        $(".right-signal").addClass("blink-anim");
        $(".hazard-light").css("fill", "rgba(210, 172, 67, 1)");
        $(".hazard-light").addClass("blink-anim");
      } else if (data.signalLights == 0) {
        $(".left-signal").css("fill", "#fff");
        $(".left-signal").removeClass("blink-anim");
        $(".right-signal").css("fill", "#fff");
        $(".right-signal").removeClass("blink-anim");
        $(".hazard-light").css("fill", "#fff");
        $(".hazard-light").removeClass("blink-anim");
      }

      if (data.lights) {
        if (data.lights == "normal") {
          $(".low-beam").css("fill", "lime");
          $(".high-beam").css("fill", "#fff");
        } else if (data.lights == "high") {
          $(".low-beam").css("fill", "lime");
          $(".high-beam").css("fill", "blue");
        } else {
          $(".low-beam").css("fill", "#fff");
          $(".high-beam").css("fill", "#fff");
        }
      }
      if (data.engineControl) {
        $(".engine-control").css("fill", "lime");
      } else {
        $(".engine-control").css("fill", "rgba(184, 20, 20, 1)");
      }
    } else {
      $(".wrapper").hide("fast", function () {
        $(".container").css("display", "none");
      });
    }
  });
});