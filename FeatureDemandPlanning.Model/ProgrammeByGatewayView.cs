
/*===============================================================================
 *
 *      Code Comment Block Here.
 *      
 *      Generated by Code Generator on 28/07/2015 12:16  
 * 
 *===============================================================================
 */

namespace FeatureDemandPlanning.Model
{
    public class ProgrammeByGatewayView : BusinessObject
    {
            public int ProgrammeId { get; set; }
            public int VehicleId { get; set; }
            public int GatewayId { get; set; }
            public string Make { get; set; }
            public string Code { get; set; }
            public string Description { get; set; }
            public string Model_Year { get; set; }
            public string Gateway { get; set; }
           
        // A blank constructor
        public ProgrammeByGatewayView() {;}
    }
}