﻿using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model.Validators
{
    public static class ComparisonVehicleExtensions
    {
        public static IEnumerable<VehicleWithIndex> ToVehicleWithIndexList(this IEnumerable<Vehicle> vehicleList)
        {
            int vehicleIndex = 1;
            if (vehicleList == null)
                return Enumerable.Empty<VehicleWithIndex>();

            return vehicleList.Select(v => new VehicleWithIndex() { VehicleIndex = vehicleIndex++, Vehicle = v });
        }
    }
}
