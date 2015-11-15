
/*===============================================================================
 *
 *      Code Comment Block Here.
 *      
 *      Generated by Code Generator on 03/06/2014 12:52  
 * 
 *===============================================================================
 */

namespace FeatureDemandPlanning.Model
{
    public class ModelEngine : BusinessObject
    {
        public string TypeName { get { return "ModelEngine"; } }

        public int ProgrammeId { get; set; }
        public string Size { get; set; }
        public string Cylinder { get; set; }
        public string Turbo { get; set; }
        public string FuelType { get; set; }
        public string Power { get; set; }
     //   public string Electrification { get; set; }
        public bool Active { get; set; }
                      
        // A blank constructor
        public ModelEngine() {;}

        public string Name
        {
            get { return string.Format("{0} {1} {2} {3}", Size + (FuelType=="Petrol" ? "" : "D"), Cylinder, (Turbo=="i"? "" : Turbo), Power); }

        }

        //[ScriptIgnore]
        //public Programme Programme
        //{
        //    get
        //    {
        //        ProgrammeDataStore ds = new ProgrammeDataStore("system");
        //        Programme retVal = new Programme();

        //        retVal = ds.ProgrammeGet(ProgrammeId);
        //        return retVal;
        //    }
        //}

    }
}