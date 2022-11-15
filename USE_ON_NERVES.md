# Use on Nerves

This doc shows the steps how to use Rclex on Nerves.

> #### Support Target {: .neutral }
>
> Currentry Rclex only support aarch64 for Nerves, following steps use rpi4 as an example.

## Create Nerves Project

```
mix nerves.new rclex_on_nerves --target rpi4
cd rclex_on_nerves
export MIX_TARGET=rpi4
mix deps.get
```

> #### Note {: .warning }
>
> If `mix deps.get` failed, you may need to create SSH key and configure config/target.exs.

## Add rclex to mix.exs and get

```elixir
  defp deps do
    [
      ...
      # FIXME when merged and hex published
      {:rclex,
       git: "https://github.com/rclex/rclex.git", branch: "improve-mix_tasks_usability-pojiro"},
      ...
    ]
  end
```

```
mix deps.get
```

## Prepare ROS 2 resoures

```
export ROS_DISTRO=foxy
mix rclex.prep.ros2
```

## Cofigure ROS 2 message types you want to use and write codes

Add ros2_message_types config to config/config.exs, like following

```elixir
config :rclex, ros2_message_types: ["std_msgs/msg/String", "geometry_msgs/msg/Twist"]
```

Generate message types codes for topic comm.

```
mix rclex.gen.msgs
```

Then Write your ROS 2 codes with Rclex.

If you change the message types in config, do `mix rclex.gen.msgs` again.

## Copy erlinit.config to rootfs_overlay/etc and add LD_LIBRARY_PATH

Copy erlinit.config from `nerves_system_***`.

```
cp deps/nerves_system_rpi4/rootfs_overlay/etc/erlinit.config rootfs_overlay/etc
```

Add `-e LD_LIBRARY_PATH=/opt/ros/foxy/lib` line like following.  
`ROS_DISTRO` is needed to be written directly, following is the case of `foxy`.

```
# Enable UTF-8 filename handling in Erlang and custom inet configuration
-e LANG=en_US.UTF-8;LANGUAGE=en;ERL_INETRC=/etc/erl_inetrc;ERL_CRASH_DUMP=/root/crash.dump
-e LD_LIBRARY_PATH=/opt/ros/foxy/lib
```

> #### Why add LD_LIBRARY_PATH explicitly {: .info }
>
> ROS 2 needs the path. If you want to know the details, please read followings
>
> - https://github.com/ros-tooling/cross_compile/issues/363
> - https://github.com/ros2/rcpputils/pull/122

## Create fw, and burn (or, upload)

```
mix firmware
mix burn # or, mix upload
```
