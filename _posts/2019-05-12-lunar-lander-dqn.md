---
layout: post
title:  "Solving Lunar Lander with Double Dueling Deep Q-Network and PyTorch"
date:   2019-05-12
categories: posts
tags: dqn pytorch
comments: true
---

### Problem Statement

The environment is called `LunarLander-v2` which is part of the Python `gym` package @lunarlander. An episode always begins with the lander module descending from the top of the screen. At each step, the agent is provided with the current state of the space vehicle which is an 8-dimensional vector of real values, indicating the horizontal and vertical positions, orientation, linear and angular velocities, state of each landing leg (left and right) and whether the lander has crashed. The agent then has to make one of four possible actions, namely do nothing, fire left orientation engine, fire main engine, or fire right orientation engine. These are 4 levers the agent must learn to control in order to land safely.

The scoring system is clearly laid out in OpenAI’s environment description. “Reward for moving from the top of the screen to landing pad and zero speed is about 100..140 points. If lander moves away from landing pad it loses reward back. Episode finishes if the lander crashes or comes to rest, receiving additional -100 or +100 points. Each leg ground contact is +10. Firing main engine is -0.3 points each frame. Solved is 200 points. Landing outside landing pad is possible, but is penalized. Fuel is infinite, so an agent can learn to fly and then land on its first attempt.”

The episode can also finish when it hits the maximum episode length of 1000 steps, as shown in the source code (`max_episode_steps=1000`). A successful solution is one that can get the agent consistently land on the target area safely i.e. with both legs touching the ground at (0, 0) at zero speed, yielding an average score of at least 200 points over 100 consecutive episode.

### Exploratory Analysis


