# Create drivers
driver1 = Driver.create(home_address: '2901 Bertland Ave, Durham, NC 27705')

# Create rides
Ride.create(start_address: '2930 W Main St, Durham, NC 27705', destination_address: '810 9th St, Durham, NC 27705', driver: driver1)
Ride.create(start_address: '621 Broad St, Durham, NC 27705', destination_address: '8210 Renaissance Pkwy, Durham, NC 27713as', driver: driver1)
Ride.create(start_address: '1829 Front St Suite D, Durham, NC 27705', destination_address: '4037 Chapel Hill Blvd, Durham, NC 27707', driver: driver1)
