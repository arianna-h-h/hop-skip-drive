# Create drivers
driver1 = Driver.create(home_address: '123 Main St')
driver2 = Driver.create(home_address: '456 Elm St')
driver3 = Driver.create(home_address: '789 Oak St')

# Create rides
Ride.create(start_address: '789 Oak St', destination_address: '101 Pine St', driver: driver1)
Ride.create(start_address: '111 Maple St', destination_address: '222 Birch St', driver: driver2)
Ride.create(start_address: '333 Walnut St', destination_address: '444 Cedar St', driver: driver1)
Ride.create(start_address: '555 Elm St', destination_address: '666 Oak St', driver: driver2)
Ride.create(start_address: '777 Pine St', destination_address: '888 Maple St', driver: driver1)
