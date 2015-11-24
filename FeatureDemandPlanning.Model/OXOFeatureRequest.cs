
/*===============================================================================
 *
 *      Code Comment Block Here.
 *      
 *      Generated by Code Generator on 16/12/2014 09:33  
 * 
 *===============================================================================
 */

using System;

namespace FeatureDemandPlanning.Model
{
    public class FeatureRequest : BusinessObject
    {
        public int Programme_Id { get; set; }
        public string Description { get; set; }
        public string Marketing_Description { get; set; }
        public string Notes { get; set; }
        public string Feature_Group { get; set; }
        public string Decision { get; set; }
        public string Created_By { get; set; }
        public DateTime? Created_On { get; set; }
        public string Updated_By { get; set; }
        public DateTime? Last_Updated { get; set; }

        // A blank constructor
        public FeatureRequest() { ;}
    }
}