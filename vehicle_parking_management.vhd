
-- Md. Nazmush Shakib Shahi
-- Islamic University of Technology (IUT)
-- Source code of "Automated vehicle parking management system"

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity vehicle_Parking_System is
port 
(
  clk,reset_n: in std_logic; -- clock and reset of the car parking system
  front_sensor_1, back_sensor_1, front_sensor_2, back_sensor_2: in std_logic; -- two sensors in the entrance and two in the exit of the car parking system
  password : in integer; -- input password 
  gate_open_1, gate_close_1, gate_open_2, gate_close_2 : in std_logic; -- Gate opening and closing detection sensors in entrance and exit gate
  GREEN_LED_1,RED_LED_1, GREEN_LED_2,RED_LED_2: out std_logic; -- signaling LEDs
  seven_seg : out std_logic; -- Seven segment display activation signal
  IN1, IN2, IN3, IN4 : out std_logic:= '0' -- Motor driver operation signal
  
);
end vehicle_Parking_System;

architecture behavioral of vehicle_Parking_System is
-- FSM States
type FSM_States is (IDLE,WAIT_PASS,WRONG_PASS,RIGHT_PASS,STOP,ALLOW,SPACE_COUNT,SPACE_FULL);
signal current_state,next_state: FSM_States;
signal counter_wait: std_logic_vector(31 downto 0);
signal red_tmp_1, green_tmp_1, red_tmp_2, green_tmp_2: std_logic;
signal space: integer:= 10; 


begin
-- Sequential signal generator
process(clk,reset_n)
begin
 if(reset_n='0') then
  current_state <= IDLE;
 elsif(rising_edge(clk)) then
  current_state <= next_state;
 end if;
end process;

-- Main process with sensitivity list
process(current_state,space,front_sensor_1,front_sensor_2,password,back_sensor_1,back_sensor_2,gate_open_1,gate_close_1,gate_open_2,gate_close_2,counter_wait)
      variable count : integer:= 0; 
      variable space_avail : integer:= 10; 
      variable m : integer:= 1; 
 begin
 case current_state is 

 when IDLE =>
 if(gate_close_1 = '1') then -- If gate is fully closed then shut down the motor
      IN1 <= '0'; 
      IN2 <= '0'; 
   end if;
 if(gate_close_2 = '1') then -- If gate is fully closed then shut down the motor
        IN3 <= '0'; 
        IN4 <= '0'; 
  end if;
 if(space_avail = "0000") then 
     next_state <= SPACE_FULL;

 elsif(front_sensor_1 = '1') then -- If the front sensor 1 is on, wait for password 
        next_state <= WAIT_PASS; 
 
 elsif(front_sensor_2 = '1') then -- If the front sensor 2 is on, a car wants to exit
        next_state <= ALLOW;   -- Allow the car to exit by opening the exit gate
          IN3 <= '1'; 
          IN4 <= '0';       
 else
  next_state <= IDLE;
 end if;

 when WAIT_PASS =>
 if(front_sensor_2 = '1') then -- If the front sensor 2 is on, a car wants to exit
     next_state <= ALLOW;   -- Allow the car to exit by opening the exit gate
        IN3 <= '1'; 
        IN4 <= '0';
      
 elsif(counter_wait <= x"00000003") then
   next_state <= WAIT_PASS;  -- Check password after 4 clock cycles
   
 elsif(password = 4747) then
    next_state <= RIGHT_PASS; -- If password is correct, let them in
      IN1 <= '1';             -- by opening the entrance gate
      IN2 <= '0'; 
 else
   next_state <= WRONG_PASS; -- If not, let them input the password again
 end if;

 when WRONG_PASS =>
  if(front_sensor_2 = '1') then  -- If the front sensor 2 is on, a car wants to exit
      next_state <= ALLOW;   -- Allow the car to exit by opening the exit gate
        IN3 <= '1';
        IN4 <= '0';
      
  elsif(password = 4747) then
      next_state <= RIGHT_PASS; -- If password is correct, let them in
        IN1 <= '1';             -- by opening the entrance gate
        IN2 <= '0';  
  else
    next_state <= WRONG_PASS; -- If not, they cannot get in until the password is right
  end if;

 when RIGHT_PASS => 
  if(gate_open_1 = '1') then  -- If gate is fully opened then shut down the motor
      IN1 <= '0'; 
      IN2 <= '0'; 
   end if;
  if(front_sensor_1 = '1' and back_sensor_1 = '1') then
     next_state <= SPACE_COUNT;  -- When another car appears while a car is entering through the gate
       IN1 <= '0';               -- operate the motor to close the gate to
       IN2 <= '1';               -- stop the next car 

 elsif(back_sensor_1= '1') then -- If the current car passed the gate and there is no next car at entrance
     next_state <= SPACE_COUNT; -- close the gate and go to IDLE state through SPACE_COUNT
       IN1 <= '0';                                   
       IN2 <= '1';              
 else
  next_state <= RIGHT_PASS;
 end if;

when STOP =>
 if(gate_close_1 = '1') then  -- If gate is fully closed then shut down the motor
      IN1 <= '0'; 
      IN2 <= '0'; 
   end if;
 if(password = 4747)then
     next_state <= RIGHT_PASS;  -- If the password is correct, let them in
       IN1 <= '1';              -- by opening the entrance gate
       IN2 <= '0'; 
 
 elsif(front_sensor_2 = '1') then -- If the front sensor 2 is on, a car wants to exit
     next_state <= ALLOW;       -- Allow the car to exit by opening the exit gate
      IN3 <= '1';
      IN4 <= '0';
 else
     next_state <= STOP;
 end if;

when ALLOW => 
 if(gate_open_2 = '1') then  -- If gate is fully opened then shut down the motor
          IN3 <= '0'; 
          IN4 <= '0';
 end if;
 if(back_sensor_2 = '1') then    -- If a car goes out from the parking area through exit gate
      next_state <= SPACE_COUNT; -- close the gate and go to IDLE state through SPACE_COUNT
        IN3 <= '0';              
        IN4 <= '1';                
 else
      next_state <= ALLOW;
 end if;

when SPACE_COUNT =>
 if(front_sensor_1='1' and back_sensor_1 = '1') then
        count := count + m ;           -- Increase count by 1 when a car enters the parking area
        space_avail := space - count;  -- Update the available space accordingly 
        next_state <= STOP;
 elsif(back_sensor_1='1') then 
        count := count + m ;           -- Increase count by 1 when a car enters the parking area
        space_avail := space - count;  -- Update the available space accordingly 
        next_state <= IDLE;
 elsif(back_sensor_2= '1') then        
        count := count - m ;           -- Decrease count by 1 when a car exits from the parking area
        space_avail := space - count;  -- Update the available space accordingly 
        next_state <= IDLE;
 else
        next_state <= SPACE_COUNT;
 end if;

when SPACE_FULL =>
 if(gate_close_1 = '1') then  -- If gate is fully closed then shut down the motor
         IN1 <= '0'; 
         IN2 <= '0'; 
   end if;
 if(front_sensor_2= '0') then    -- If no car tries to exit, stay at SPACE_FULL state
        next_state <= SPACE_FULL;

 elsif(front_sensor_2= '1') then  -- If a car tries to exit
        next_state <= ALLOW;      -- Allow the car to exit by opening the exit gate
         IN3 <= '1';
         IN4 <= '0';
 else
        next_state <= SPACE_FULL;
 end if;
 
end case;
end process;
 -- wait for password
process(clk,reset_n)
 begin
  if(reset_n='0') then
        counter_wait <= (others => '0');
  elsif(rising_edge(clk))then
     if(current_state=WAIT_PASS)then
        counter_wait <= counter_wait + x"00000001";
     else 
        counter_wait <= (others => '0');
     end if;
  end if;
end process;

 -- Display and LED output 
process(clk) 
 begin
  if(rising_edge(clk)) then
   case(current_state) is
 when IDLE => 
 green_tmp_1 <= '0';
 red_tmp_1 <= '0';
 green_tmp_2 <= '0';
 red_tmp_2 <= '1';
 seven_seg <= '0'; -- Off
 
 when WAIT_PASS =>
 green_tmp_1 <= '0';
 red_tmp_1 <= '1';  -- When a car at entrance gate, RED LED 1 is turned on to stop the car
 green_tmp_2 <= '0';
 red_tmp_2 <= '1';
 seven_seg <= '0'; -- Off

 when WRONG_PASS =>
 green_tmp_1 <= '0';  
 red_tmp_1 <= '1';  -- If password is wrong, RED LED 1 stay turned on
 green_tmp_2 <= '0';
 red_tmp_2 <= '1';
 seven_seg <= '0'; -- Off
  
 when RIGHT_PASS =>
 green_tmp_1 <= '1'; -- If password is correct, GREEN LED 1 is turned on
 red_tmp_1 <= '0'; 
 green_tmp_2 <= '0';
 red_tmp_2 <= '1';
 seven_seg <= '0'; -- Off
  
 when STOP =>
 green_tmp_1 <= '0';
 red_tmp_1 <= '1'; -- Stop the next car and RED LED 1 is turned on
 green_tmp_2 <= '0';
 red_tmp_2 <= '1';
 seven_seg <= '0'; -- Off
  
 when ALLOW =>
 green_tmp_1 <= '0';
 red_tmp_1 <= '0';
 green_tmp_2 <= '1'; -- When a car tries to exit, Green LED 2 is turned on
 red_tmp_2 <= '0'; -- When a car tries to exit, RED LED 2 is turned off
 seven_seg <= '0'; -- Off

 when SPACE_FULL =>
  green_tmp_1 <= '0';
 red_tmp_1 <= '1'; -- When total available space is full, RED LED 1 is turned on
 green_tmp_2 <= '0';
 red_tmp_2 <= '1';
 seven_seg <= '1'; -- Turn on the display  to show "FULL" on it

 when others => 
 green_tmp_1 <= '0';
 red_tmp_1 <= '0';
 green_tmp_2 <= '0';
 red_tmp_2 <= '1'; 
 seven_seg <= '0'; -- Off
 
  end case;
 end if;
 end process;
  RED_LED_1 <= red_tmp_1  ;
  GREEN_LED_1 <= green_tmp_1;
  RED_LED_2 <= red_tmp_2  ;
  GREEN_LED_2 <= green_tmp_2;
end behavioral;
