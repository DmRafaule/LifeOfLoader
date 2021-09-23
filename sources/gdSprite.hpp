#ifndef MYSPRITE_H
#define MYSPRITE_H

#include <Godot.hpp>
#include <Sprite.hpp>

namespace godot {

class MySprite : public Sprite {
   GODOT_CLASS(MySprite, Sprite)

private:
   float time_passed;

public:
   static void _register_methods();

   MySprite();
   ~MySprite();

   void _init(); // our initializer called by Godot

   void _process(float delta);
};

}

#endif