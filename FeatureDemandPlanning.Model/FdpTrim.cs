﻿using FeatureDemandPlanning.Model.Extensions;

namespace FeatureDemandPlanning.Model
{
    public class FdpTrim : ModelTrim
    {
        public int? FdpTrimId { get; set; }
        public new int? ProgrammeId { get; set; }
        public Programme Programme { get; set; }
        public string Gateway { get; set; }

        public virtual string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpTrimId.GetValueOrDefault().ToString(),
                CreatedOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                CreatedBy,
                Programme.GetDisplayString(),
                Gateway,
                Name,
                Level
            };
        }
    }
}
