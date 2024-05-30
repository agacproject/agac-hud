var current = 'normal'

window.addEventListener('message', function(event) {
    switch(event.data.type){
        case 'open':
            if (event.data.data == 'normal') {
                if (current == 'vehicle') {
                    $('#hud2class').fadeOut(200);
                }
                setTimeout(() => {
                    $('#hud1class').fadeIn();
                    current = 'normal'
                }, 250);
            } else if (event.data.data == 'vehicle') {
                if (current == 'normal') {
                    $('#hud1class').fadeOut(200);
                }
                setTimeout(() => {
                    $('#hud2class').fadeIn();
                    current = 'vehicle'
                }, 250);
            }
            break;
        case 'update':
            update(event.data.data);
            break;
        case 'updatespeed':
            // console.log(event.data.fuel)
            // setProgress(event.data.fuel, 100, 'fuelcar');
            // setProgress(event.data.speed, 360, 'kmhcar');
            updateVehicleData(event.data.data);
        break;
        case 'hudactive':
            $('body').removeClass('hidden').addClass('block');
        break;
        case 'huddeactive':
            $('body').removeClass('block').addClass('hidden');
        break;
    }
})

function updateVoice(level) {
    if (level == 3) {
        $('#talking3').css('border-width', '2px');
        $('#talking2').css('border-width', '2px');
        $('#talking1').css('border-width', '2px');
    } else if (level == 2) {
        $('#talking3').css('border-width', '0px');
        $('#talking2').css('border-width', '2px');
        $('#talking1').css('border-width', '2px');
    } else if (level == 1) {
        $('#talking3').css('border-width', '0px');
        $('#talking2').css('border-width', '0px');
        $('#talking1').css('border-width', '2px');
    }
}

function update(data) {
    updateVehicle(data.health, '.healthcar');
    updateVehicle(data.armor, '.armorcar');
    $('.healthInside').css('height', data.health+'%');
    $('.armorInside').css('height', data.armor+'%');
    $('.hungryInside').css('height', data.hungry+'%');
    $('.thirstInside').css('height', data.thirst+'%');
    $('.oxygenInside').css('height', data.oxygen+'%');
    $('.stressInside').css('height', data.stress+'%');
    if (data.talking == true) {
        $('.talkingcolor').css('border-color', 'rgb(21, 128, 61)');
        $('.radiocolor').css('background-color', 'rgb(249, 249, 249)');
    } else if (data.talking == 'radio') {
        $('.talkingcolor').css('border-color', 'rgb(228, 221, 24)');
        $('.radiocolor').css('background-color', 'rgb(228, 221, 24)');
    } else if (data.talking == false) {
        $('.talkingcolor').css('border-color', 'rgb(249, 249, 249)');
        $('.radiocolor').css('background-color', 'rgb(249, 249, 249)');
    }
    if (data.radio == true) {
        $('.radiocolor').css('display', 'block');
    } else if (data.radio == false) {
        $('.radiocolor').css('display', 'none');
    }
    if (data.voicelevel == 3) {
        $('#talking3').css('border-width', '2px');
        $('#talking2').css('border-width', '2px');
        $('#talking1').css('border-width', '2px');
    } else if (data.voicelevel == 2) {
        $('#talking3').css('border-width', '0px');
        $('#talking2').css('border-width', '2px');
        $('#talking1').css('border-width', '2px');
    } else if (data.voicelevel == 1) {
        $('#talking3').css('border-width', '0px');
        $('#talking2').css('border-width', '0px');
        $('#talking1').css('border-width', '2px');
    }
}

function updateVehicleData(data) {
    setProgress(data.fuel, 100, 'fuelcar');
    setProgress(data.speed, 360, 'kmhcar');
    $('#vehiclekmhtext').html(data.speed);
}

// setProgress(50, 100, 'fuelcar');
// setProgress(192, 360, 'kmhcar');
function setProgress(percentage, max, element) {
    const circle = document.getElementById(element);
    const circumference = parseFloat(circle.getAttribute("stroke-dasharray"));
    const offset = circumference - (percentage / max) * circumference;
    
    // Animasyonlu geçiş
    circle.style.transition = 'stroke-dashoffset 1s ease-in-out';
    
    // SetAttribute kullanarak stroke-dashoffset değerini güncelleme
    circle.setAttribute("stroke-dashoffset", offset);
}



function updateVehicle(percent, element) {
    var circle = document.querySelector(element);
    var circumference = "111" * 2 * Math.PI;
    var html = $(element).parent().parent().find("span");

    if (element == ".armorcar") {
        circle.style.strokeDasharray = `${circumference} ${circumference}`;
        circle.style.strokeDashoffset = `${circumference}`;

        const offset = circumference - ((-percent * 50) / 100 / 100) * circumference;
        circle.style.strokeDashoffset = -offset;
    } else if (element == ".healthcar") {
        circle.style = `${circumference} ${circumference}`;
        circle.style.strokeDasharray = `${circumference} ${circumference}`;
        circle.style.strokeDashoffset = `${circumference}`;

        const offset = circumference - ((-percent * 50) / 100 / 100) * circumference;
        circle.style.strokeDashoffset = offset;
    }

    html.text(Math.round(percent));
}