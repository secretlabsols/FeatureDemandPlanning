﻿using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Attributes;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.ViewModel;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Controllers
{
    public class DerivativeMappingController : ControllerBase
    {
        public DerivativeMappingController()
            : base()
        {
            ControllerType = ControllerType.SectionChild;
        }
        [HttpGet]
        [ActionName("Index")]
        public ActionResult DerivativeMappingPage()
        {
            return RedirectToAction("DerivativeMappingPage");
        }
        [HttpGet]
        public async Task<ActionResult> DerivativeMappingPage(DerivativeMappingParameters parameters)
        {
            var filter = new DerivativeMappingFilter()
            {
                PageIndex = PageIndex,
                PageSize = PageSize
            };
            return View(await DerivativeMappingViewModel.GetModel(DataContext, filter));
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListDerivativeMappings(DerivativeMappingParameters parameters)
        {
            ValidateDerivativeMappingParameters(parameters, DerivativeMappingParametersValidator.NoValidation);

            var filter = new DerivativeMappingFilter()
            {
                FilterMessage = parameters.FilterMessage,
                CarLine = parameters.CarLine,
                ModelYear = parameters.ModelYear,
                Gateway = parameters.Gateway,
                Action = DerivativeMappingAction.Mappings
            };
            filter.InitialiseFromJson(parameters);

            var results = await DerivativeMappingViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.DerivativeMappings.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(DerivativeMappingParameters parameters)
        {
            ValidateDerivativeMappingParameters(parameters, DerivativeMappingParametersValidator.DerivativeMappingIdentifier);

            var filter = DerivativeMappingFilter.FromDerivativeMappingParameters(parameters);
            filter.Action = DerivativeMappingAction.Mapping;

            var derivativeMappingView = await DerivativeMappingViewModel.GetModel(DataContext, filter);

            return PartialView("_ContextMenu", derivativeMappingView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(DerivativeMappingParameters parameters)
        {
            ValidateDerivativeMappingParameters(parameters, DerivativeMappingParametersValidator.Action);

            var filter = DerivativeMappingFilter.FromDerivativeMappingParameters(parameters);
            var derivativeMappingView = await DerivativeMappingViewModel.GetModel(DataContext, filter);

            return PartialView(GetContentPartialViewName(parameters.Action), derivativeMappingView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(DerivativeMappingParameters parameters)
        {
            ValidateDerivativeMappingParameters(parameters, DerivativeMappingParametersValidator.DerivativeIdentifierWithAction);
            ValidateDerivativeMappingParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> Delete(DerivativeMappingParameters parameters)
        {
            var derivativeMappingView = await GetModelFromParameters(parameters);
            if (derivativeMappingView.DerivativeMapping is EmptyFdpDerivativeMapping)
            {
                return JsonGetFailure("DerivativeMapping does not exist");
            }

            derivativeMappingView.DerivativeMapping = await DataContext.Vehicle.DeleteFdpDerivativeMapping(FdpDerivativeMapping.FromParameters(parameters));
            if (derivativeMappingView.DerivativeMapping is EmptyFdpDerivativeMapping)
            {
                return JsonGetFailure(string.Format("DerivativeMapping '{0}' could not be deleted", derivativeMappingView.DerivativeMapping.ImportDerivativeCode));
            }

            return JsonGetSuccess();
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> Copy(DerivativeMappingParameters parameters)
        {
            var derivativeMappingView = await GetModelFromParameters(parameters);
            if (derivativeMappingView.DerivativeMapping is EmptyFdpDerivativeMapping)
            {
                return JsonGetFailure("DerivativeMapping does not exist");
            }

            derivativeMappingView.DerivativeMapping = await DataContext.Vehicle.CopyFdpDerivativeMappingToGateway(FdpDerivativeMapping.FromParameters(parameters), parameters.CopyToGateways);
            if (derivativeMappingView.DerivativeMapping is EmptyFdpDerivativeMapping)
            {
                return JsonGetFailure(string.Format("DerivativeMapping '{0}' could not be copied", derivativeMappingView.DerivativeMapping.ImportDerivativeCode));
            }

            return JsonGetSuccess();
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> CopyAll(DerivativeMappingParameters parameters)
        {
            var derivativeMappingView = await GetModelFromParameters(parameters);
            if (derivativeMappingView.DerivativeMapping is EmptyFdpDerivativeMapping)
            {
                return JsonGetFailure("DerivativeMapping does not exist");
            }

            derivativeMappingView.DerivativeMapping = await DataContext.Vehicle.CopyFdpDerivativeMappingsToGateway(FdpDerivativeMapping.FromParameters(parameters), parameters.CopyToGateways);
            if (derivativeMappingView.DerivativeMapping is EmptyFdpDerivativeMapping)
            {
                return JsonGetFailure(string.Format("DerivativeMappings could not be copied", derivativeMappingView.DerivativeMapping.ImportDerivativeCode));
            }

            return JsonGetSuccess();
        }
        private string GetContentPartialViewName(DerivativeAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private async Task<DerivativeMappingViewModel> GetModelFromParameters(DerivativeMappingParameters parameters)
        {
            return await DerivativeMappingViewModel.GetModel(DataContext, DerivativeMappingFilter.FromDerivativeMappingParameters(parameters));
        }
        private void ValidateDerivativeMappingParameters(DerivativeMappingParameters parameters, string ruleSetName)
        {
            var validator = new DerivativeMappingParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }
    }

    internal class DerivativeMappingParametersValidator : AbstractValidator<DerivativeMappingParameters>
    {
        public const string DerivativeMappingIdentifier = "DERIVATIVE_MAPPING_ID";
        public const string NoValidation = "NO_VALIDATION";
        public const string Action = "ACTION";
        public const string DerivativeIdentifierWithAction = "DERIVATIVE_ID_WITH_ACTION";

        public DerivativeMappingParametersValidator()
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(DerivativeMappingIdentifier, () =>
            {
                RuleFor(p => p.DerivativeMappingId).NotNull().WithMessage("'DerivativeMappingId' not specified");
            });
            RuleSet(Action, () =>
            {
                RuleFor(p => p.Action).NotEqual(a => DerivativeMappingAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(DerivativeIdentifierWithAction, () =>
            {
                RuleFor(p => p.DerivativeMappingId).NotNull().WithMessage("'DerivativeMappingId' not specified");
                RuleFor(p => p.Action).NotEqual(a => DerivativeMappingAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(Enum.GetName(typeof(DerivativeMappingAction), DerivativeMappingAction.Delete), () =>
            {
                RuleFor(p => p.DerivativeMappingId).NotNull().WithMessage("'DerivativeMappingId' not specified");
            });
        }
    }
}