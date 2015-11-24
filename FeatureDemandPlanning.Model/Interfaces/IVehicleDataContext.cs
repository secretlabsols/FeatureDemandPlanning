﻿using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Context;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IVehicleDataContext
    {
        IVehicle GetVehicle(VehicleFilter filter);
        IVehicle GetVehicle(ProgrammeFilter filter);

        IEnumerable<IVehicle> ListAvailableVehicles(VehicleFilter filter);
        
        IEnumerable<Programme> ListProgrammes(ProgrammeFilter filter);
        Programme GetProgramme(ProgrammeFilter filter);

        IEnumerable<ModelBody> ListBodies(ProgrammeFilter filter);
        IEnumerable<Derivative> ListDerivatives(DerivativeFilter filter);
        IEnumerable<Gateway> ListGateways(ProgrammeFilter programmeFilter);
        IEnumerable<ModelTransmission> ListTransmissions(ProgrammeFilter filter);
        IEnumerable<ModelEngine> ListEngines(ProgrammeFilter filter);
        IEnumerable<ModelTrim> ListTrim(ProgrammeFilter filter);
        IEnumerable<Feature> ListFeatures(ProgrammeFilter filter);
        IEnumerable<FeatureGroup> ListFeatureGroups(ProgrammeFilter filter);
        IEnumerable<TrimLevel> ListTrimLevels(ProgrammeFilter programmeFilter);

        // Derivatives and mappings

        Task<FdpDerivative> DeleteFdpDerivative(FdpDerivative derivativeToDelete);
        Task<FdpDerivative> GetFdpDerivative(DerivativeFilter filter);
        Task<PagedResults<FdpDerivative>> ListFdpDerivatives(DerivativeFilter filter);

        Task<FdpDerivativeMapping> DeleteFdpDerivativeMapping(FdpDerivativeMapping fdpDerivativeMapping);
        Task<FdpDerivativeMapping> GetFdpDerivativeMapping(DerivativeMappingFilter filter);
        Task<PagedResults<FdpDerivativeMapping>> ListFdpDerivativeMappings(DerivativeMappingFilter filter);

        Task<FdpDerivativeMapping> CopyFdpDerivativeMappingToGateway(FdpDerivativeMapping fdpDerivativeMapping, IEnumerable<string> gateways);
        Task<FdpDerivativeMapping> CopyFdpDerivativeMappingsToGateway(FdpDerivativeMapping fdpDerivativeMapping, IEnumerable<string> gateways);

        // Features and mappings

        Task<FdpFeature> DeleteFdpFeature(FdpFeature featureToDelete);
        Task<FdpFeature> GetFdpFeature(FeatureFilter filter);
        Task<PagedResults<FdpFeature>> ListFdpFeatures(FeatureFilter filter);

        Task<FdpFeatureMapping> DeleteFdpFeatureMapping(FdpFeatureMapping fdpFeatureMapping);
        Task<FdpFeatureMapping> GetFdpFeatureMapping(FeatureMappingFilter filter);
        Task<PagedResults<FdpFeatureMapping>> ListFdpFeatureMappings(FeatureMappingFilter filter);

        Task<FdpFeatureMapping> CopyFdpFeatureMappingToGateway(FdpFeatureMapping fdpFeatureMapping, IEnumerable<string> gateways);
        Task<FdpFeatureMapping> CopyFdpFeatureMappingsToGateway(FdpFeatureMapping fdpFeatureMapping, IEnumerable<string> gateways);

        Task<FdpSpecialFeatureMapping> DeleteFdpSpecialFeatureMapping(FdpSpecialFeatureMapping fdpSpecialFeatureMapping);
        Task<FdpSpecialFeatureMapping> GetFdpSpecialFeatureMapping(SpecialFeatureMappingFilter filter);
        Task<PagedResults<FdpSpecialFeatureMapping>> ListFdpSpecialFeatureMappings(SpecialFeatureMappingFilter filter);

        Task<FdpSpecialFeatureMapping> CopyFdpSpecialFeatureMappingToGateway(FdpSpecialFeatureMapping fdpSpecialFeatureMapping, IEnumerable<string> gateways);
        Task<FdpSpecialFeatureMapping> CopyFdpSpecialFeatureMappingsToGateway(FdpSpecialFeatureMapping fdpSpecialFeatureMapping, IEnumerable<string> gateways);

        // Trim and mappings

        Task<FdpTrim> DeleteFdpTrim(FdpTrim trimToDelete);
        Task<FdpTrim> GetFdpTrim(TrimFilter filter);
        Task<PagedResults<FdpTrim>> ListFdpTrims(TrimFilter filter);

        Task<FdpTrimMapping> DeleteFdpTrimMapping(FdpTrimMapping fdpTrimMapping);
        Task<FdpTrimMapping> GetFdpTrimMapping(TrimMappingFilter filter);
        Task<PagedResults<FdpTrimMapping>> ListFdpTrimMappings(TrimMappingFilter filter);

        Task<FdpTrimMapping> CopyFdpTrimMappingToGateway(FdpTrimMapping fdpTrimMapping, IEnumerable<string> gateways);
        Task<FdpTrimMapping> CopyFdpTrimMappingsToGateway(FdpTrimMapping fdpTrimMapping, IEnumerable<string> gateways);
    }
}
