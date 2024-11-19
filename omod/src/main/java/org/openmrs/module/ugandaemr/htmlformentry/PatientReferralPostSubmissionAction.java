package org.openmrs.module.ugandaemr.htmlformentry;

import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.module.htmlformentry.CustomFormSubmissionAction;
import org.openmrs.module.htmlformentry.FormEntrySession;

public class PatientReferralPostSubmissionAction implements CustomFormSubmissionAction {
    @Override
    public void applyAction(FormEntrySession formEntrySession) {
        UgandaEMRService ugandaemrService=Context.getService(UgandaEMRService.class);
        if (formEntrySession.getEncounter().getEncounterType() == Context.getEncounterService().getEncounterTypeByUuid("3e8354f7-31b3-4862-a52e-ff41a1ee60af")) {
            ugandaemrService.createPatientHIVSummaryEncounterOnTransferIn(formEntrySession);
        }

    }



}
