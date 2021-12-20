void setup() {
  size(800, 600);
}

void draw() {
  background(0);

  int x = mouseX;
  int eased_x = ease(x, 0, width); // value, min_value, max_value

  // show
  noStroke();
  fill(255);

  rect(x, height/2 - 20, 10, 10);
  rect(eased_x, height/2 + 20, 10, 10);
}

int ease(int v, int min, int max) {
  float value = float(v);
  value = map(value, min, max, 0, 1);

  // easing HERE
  // see different functions here https://easings.net/de

  // value = 1 - pow(1 - value, 3);
  // value =  sin((value * PI) / 2);
  // value = sqrt(1 - pow(value - 1, 2));
  value = 1 - (1 - value) * (1 - value);

  return int(map(value, 0, 1, min, max));
}
