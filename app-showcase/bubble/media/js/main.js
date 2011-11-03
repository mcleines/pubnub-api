var bubbles = [];
var placed = false;

var large_circle = new Path.Circle([676, 433], 100);
large_circle.fillColor = 'black';
large_circle.strokeColor = 'black';
large_circle.strokeWidth = 8;

var text = new PointText(view.center);
text.fillColor = 'white';
text.characterStyle.fontSize = 35;
text.paragraphStyle.justification = 'center';
text.content = 'PubNub';
text.position = large_circle.center;

var group = new Group([large_circle, text]);
group.visible = false;


function onMouseMove(event) {
  if (placed === false) {
    for (var i = 0; i < bubbles.length; i++) {
      bubbles[i].children[0].position = event.point;
      bubbles[i].position = large_circle.bounds.center;  
    }
  }
}

function onFrame(event) {
  for (var i = 0; i < bubbles.length; i++) {
    if (placed === false) {
      bubbles[i].children[0].rotate(1);
    }
    else {
      bubbles[i].scale(.99); 
    }
  }
}

function onMouseDown(event) {
  
  for (var i = 0; i < bubbles.length; i++) {
    if (placed === true) {
      hit_result = bubbles[i].hitTest(event.point);
      if ((hit_result !== null) && (hit_result !== undefined)) {
        bubbles[i].scale(1.5);
      }
    } 

    if (placed === false) {
      placed = true;
      bubbles[i].opacity = 1;
      bubbles[i].position = event.point;
      bubbles[i].dashArray = [14, 0];
    }
  }
}


$("#place").click( function(e) {
  e.preventDefault();

  placed = false;

  var new_bubble = group.clone(); 
  
  new_bubble.children[1].content = $("#bubble_text").val();
  new_bubble.children[1].position = new_bubble.position;
  new_bubble.visible = true;
  new_bubble.children[0].dashArray = [14, 4];
  new_bubble.opacity = .5;

  bubbles.push(new_bubble);

});

