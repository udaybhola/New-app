module SimulationHelper
  extend ActiveSupport::Concern

  def is_in_simulation_mode?
    ENV["SIMULATION_MODE"].to_i == 1
  end
end
