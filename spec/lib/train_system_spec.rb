# frozen_string_literal: true

require './lib/underground_system'

RSpec.describe UndergroundSystem do
  it 'works' do
    tube = UndergroundSystem.new
    tube.check_in(45, 'Layton', 3)
    tube.check_in(32, 'Paradise', 8)
    tube.check_out(45, 'Waterloo', 15)
    tube.check_out(32, 'Cambridge', 22)
    ans = tube.get_average_time('Paradise', 'Cambridge')
    expect(ans).to eq 14
  end

  it 'will work for customers who travelled same route few times' do
    tube = UndergroundSystem.new
    tube.check_in(1, 'Layton', 3)
    tube.check_in(2, 'Layton', 6)
    tube.check_in(3, 'Waterloo', 7)
    tube.check_out(1, 'Paradise', 8)
    tube.check_out(3, 'Cambridge', 10)
    tube.check_in(1, 'Layton', 25)
    tube.check_out(2, 'Paradise', 30)
    tube.check_out(1, 'Paradise', 33)

    expect(tube.get_average_time('Layton', 'Paradise')).to eq(12.33)
  end

  it 'does ignore unpaired events' do
    tube = UndergroundSystem.new
    tube.check_in(1, 'Layton', 3)
    tube.check_in(2, 'Layton', 5)
    tube.check_out(1, 'Paradise', 8)
    tube.check_out(2, 'Waterloo', 22)

    expect(tube.get_average_time('Layton', 'Paradise')).to eq(5.0)
  end

  it 'will ignore route if opposite direction' do
    tube = UndergroundSystem.new
    tube.check_in(1, 'Layton', 3)
    tube.check_in(2, 'Paradise', 5)
    tube.check_out(1, 'Paradise', 8)
    tube.check_out(2, 'Layton', 22)

    expect(tube.get_average_time('Layton', 'Paradise')).to eq(5.0)
  end
end
