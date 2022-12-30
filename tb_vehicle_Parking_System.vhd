
-- Md. Nazmush Shakib Shahi
-- Islamic University of Technology (IUT)
-- Testbench code of "Automated vehicle parking management system"

library ieee;
use ieee.std_logic_1164.all;
 
entity tb_vehicle_parking_system is
end tb_vehicle_parking_system;
 
architecture behavioral of tb_vehicle_parking_system is 
 
    -- Component Declaration for the vehicle parking system 
 
    component vehicle_parking_system
    port(
         clk : in  std_logic;
         reset_n : in  std_logic;
         front_sensor_1 : in  std_logic;
         back_sensor_1 : in  std_logic;
         front_sensor_2: in std_logic;
         back_sensor_2: in std_logic;
         password : in  integer;
         gate_open_1 : in std_logic;
         gate_close_1 : in std_logic;
         gate_open_2 : in std_logic;
         gate_close_2 : in std_logic;
         GREEN_LED_1 : out  std_logic;
         RED_LED_1 : out  std_logic;
         GREEN_LED_2 : out std_logic;
         RED_LED_2: out std_logic;
         seven_seg : out std_logic;
         IN1 : out std_logic;
         IN2 : out std_logic;
         IN3 : out std_logic;
         IN4 : out std_logic
        );
    end component;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset_n : std_logic := '0';
   signal front_sensor_1 : std_logic := '0';
   signal back_sensor_1 : std_logic := '0';
   signal front_sensor_2 : std_logic := '0';
   signal back_sensor_2 : std_logic := '0';
   signal password : integer; 
   signal gate_open_1 : std_logic := '0';
   signal gate_close_1 : std_logic := '0';
   signal gate_open_2 : std_logic := '0';
   signal gate_close_2 : std_logic := '0';
 

  --Outputs
   signal GREEN_LED_1 : std_logic;
   signal RED_LED_1 : std_logic;
   signal GREEN_LED_2 : std_logic;
   signal RED_LED_2 : std_logic;
   signal seven_seg: std_logic;
   signal IN1: std_logic;
   signal IN2: std_logic;
   signal IN3: std_logic;
   signal IN4: std_logic;

  -- Clock period declarations
   constant clk_period : time := 10 ns;
 
begin
  -- Initiate the car parking system 
   vehicle_park_system: vehicle_parking_system port map (
          clk => clk,
          reset_n => reset_n,
          front_sensor_1 => front_sensor_1,
          back_sensor_1 => back_sensor_1,
          front_sensor_2 => front_sensor_2,
          back_sensor_2 => back_sensor_2,
          password => password,
          gate_open_1 => gate_open_1,
          gate_close_1 => gate_close_1,
          gate_open_2 => gate_open_2,
          gate_close_2 => gate_close_2,
          GREEN_LED_1 => GREEN_LED_1,
          RED_LED_1 => RED_LED_1,
          GREEN_LED_2 => GREEN_LED_2,
          RED_LED_2 => RED_LED_2,
          seven_seg => seven_seg,
          IN1 => IN1,
          IN2 => IN2,
          IN3 => IN3,
          IN4 => IN4
        );

  -- Clock process initialization
  clk_process :process
   begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
  end process;

  -- Stimulus process
  stim_proc: process
   begin  
       reset_n <= '0';
  front_sensor_1 <= '0';
  back_sensor_1 <= '0';
  front_sensor_2 <= '0';
  back_sensor_2 <= '0';

  gate_open_1 <= '0';
  gate_close_1 <= '0';
  gate_open_2 <= '0';
  gate_close_2 <= '0';
  
  password <= 0000;
  
      wait for clk_period*5;
  reset_n <= '1';

  wait for clk_period*5;
  front_sensor_1 <= '1';
  password <= 5263;

  wait for clk_period*10;
  password <= 4747;

  wait for clk_period*5;
   gate_open_1 <= '1';

  wait for clk_period*5;
  back_sensor_1 <= '1';
  gate_open_1 <= '0';
  password <= 3326;
 
  wait for clk_period*5;--new
   gate_close_1 <= '1';
  wait for clk_period*2;
  password <= 4747;
  back_sensor_1 <= '0';

  wait for clk_period*5;--new
   gate_close_1 <= '0';
  
  wait for clk_period*5;
   gate_open_1 <= '1';
  password <= 0000;
  front_sensor_1 <= '0'; 
  wait for clk_period*2;
  back_sensor_1 <= '1';

  wait for clk_period*5;
   gate_open_1 <= '0';
  
  wait for clk_period*5;
  gate_close_1 <= '1';
  back_sensor_1 <= '0';
  
  wait for clk_period*5;
   gate_close_1 <= '0';
  front_sensor_2 <= '1';

  wait for clk_period*5;
  gate_open_2 <= '1';
  front_sensor_2 <= '0';
  wait for clk_period*2;
  back_sensor_2 <= '1';

  wait for clk_period*5;--new
   gate_open_2 <= '0';
  
  wait for clk_period*3;--new
  gate_close_2 <= '1';
  back_sensor_2 <= '0';

  wait for clk_period*5;--new
   gate_close_2 <= '0';

 -- insert more stimulus here 

      wait;
   end process;

END;
