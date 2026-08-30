@define-color foreground {color15};
@define-color background {background};
@define-color color0 {color0};
@define-color color1 {color1};
@define-color color2 {color2};
@define-color color8 {color8};
@define-color color12 {color12};
@define-color color14 {color14};
@define-color color15 {color15};

* {{
  font-family: "Source Code Pro Medium", MesloLGS, monospace;
  font-size: 11px;
}}

window#waybar {{
  background-color: @background;
  color: @color15;
}}

widget>* {{
  padding: 0 3px;
  margin: 0;
}}

.modules-left,
.modules-center,
.modules-right {{
  padding: 0;
}}

#workspaces {{
  padding: 0;
}}

#workspaces button {{
  margin: 0;
  padding: 0 0.9em;
  background: transparent;
  color: @color15;
}}

#workspaces .active * {{
  background: none;
  color: @color14;
}}

#mode {{
  background: @color8;
  border-bottom: 3px solid white;
}}

#temperature{{
  padding-left: 1px;
}}

#cpu{{
  padding-right: 1px;
}}

@keyframes pulse-green {{
  to {{
    background-color: @color14;
  }}
}}

#battery.charging {{
  color: @color14;
}}

#custom-network.wifi-vpn-up {{
  color: @color12;
}}

#custom-network.wifi-up {{
  color: @color1;
  animation: pulse-wifi-up 1.5s ease-out 1;
}}

#custom-network.network-down {{
  color: @color8;
}}

@keyframes pulse-wifi-up {{
  0%   {{ opacity: 0.3; }}
  30%  {{ opacity: 1;   }}
  60%  {{ opacity: 0.4; }}
  100% {{ opacity: 1;   }}
}}

@keyframes pulse-red {{
  to {{
    background-color: @color1;
  }}
}}

#battery.warning:not(.charging) {{
  color: @color15;
  animation-name: pulse-red;
  animation-duration: 4s;
  animation-timing-function: linear;
  animation-iteration-count: infinite;
  animation-direction: alternate;
}}

tooltip {{
  color: @color15;
  background-color: #000000;
  border: 1px solid @color8;
}}