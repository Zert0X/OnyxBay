import { useBackend } from '../backend';
import { useLocalState } from '../backend';
import { Box, Button, Input, LabeledList, NoticeBox, ProgressBar, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

const SCREENS = [
  ['outbreak_dashboard', 'Outbreak Dashboard'],
  ['sample_intake', 'Sample Intake'],
  ['rapid_assay', 'Rapid Assay'],
  ['culture_workbench', 'Culture Workbench'],
  ['mutation_planner', 'Mutation Planner'],
  ['treatment_builder', 'Treatment Builder'],
  ['quarantine_protocols', 'Quarantine & Protocols'],
  ['audit_log', 'Audit Log'],
];

export const Disease2Console = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    screen,
    machineType,
    busy,
    dishInserted,
    syringeInserted,
    sampleInserted,
    growth,
    rapidAssay,
    pressureAxes,
    pressureForecast,
    pathways,
    riskProfiles,
    requiresRoleConfirmation,
    cmoConfirmed,
    rdConfirmed,
    systemAlerts,
    canReadAuditLog,
    auditLog,
    pathogens,
    pathogenPool,
    antibodies,
    effects,
    powerOn,
  } = data;
  const [cmoReason, setCmoReason] = useLocalState(context, 'cmoReason', '');
  const [rdReason, setRdReason] = useLocalState(context, 'rdReason', '');

  return (
    <Window width={720} height={620}>
      <Window.Content scrollable>
        <Section title={`Disease2 // ${machineType || 'console'}`}>
          <Tabs>
            {SCREENS.map(([id, label]) => (
              <Tabs.Tab key={id} selected={screen === id}>{label}</Tabs.Tab>
            ))}
          </Tabs>
        </Section>

        {!!busy && <NoticeBox info>{busy}</NoticeBox>}

        <Section title="Outbreak Dashboard">
          {(systemAlerts || []).map((alert, i) => (
            <NoticeBox key={alert.id || i} danger={alert.severity === 'danger'} warning={alert.severity === 'warning'} mb={1}>
              <b>{alert.title}</b>: {alert.details}
            </NoticeBox>
          ))}
          <LabeledList>
            <LabeledList.Item label="Dish">{dishInserted ? 'Loaded' : 'Empty'}</LabeledList.Item>
            <LabeledList.Item label="Syringe">{syringeInserted ? 'Loaded' : 'Empty'}</LabeledList.Item>
            <LabeledList.Item label="Vial">{sampleInserted ? 'Loaded' : 'Empty'}</LabeledList.Item>
            <LabeledList.Item label="Growth">
              <ProgressBar value={(growth || 0) / 100} />
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Sample Intake">
          {(pathogenPool || []).map((p, i) => (
            <Box key={i} mb={1}>
              {p.name} ({p.spreadType})
              <Button ml={1} onClick={() => act('isolate', { reference: p.reference })}>Isolate</Button>
            </Box>
          ))}
          <Button icon="eject" onClick={() => act('eject')}>Eject Sample</Button>
        </Section>

        <Section title="Rapid Assay">
          {rapidAssay ? (
            <LabeledList>
              <LabeledList.Item label="Quick ETA">{rapidAssay.eta}</LabeledList.Item>
              <LabeledList.Item label="Likely Tropism">{rapidAssay.tropism}</LabeledList.Item>
              <LabeledList.Item label="Vulnerability Class">{rapidAssay.vulnerabilityClass}</LabeledList.Item>
              <LabeledList.Item label="Suppressor">{rapidAssay.suppressor}</LabeledList.Item>
            </LabeledList>
          ) : <NoticeBox>No sample for rapid assay.</NoticeBox>}
        </Section>

        <Section title="Culture Workbench">
          <Stack vertical>
            {(pressureAxes || []).map((axis, i) => (
              <Stack.Item key={i}>
                <Box>{axis.label}: {axis.value}/{axis.max}</Box>
                <ProgressBar value={axis.max ? axis.value / axis.max : 0} />
              </Stack.Item>
            ))}
          </Stack>
          {pressureForecast && (
            <LabeledList>
              <LabeledList.Item label="Growth Forecast">{pressureForecast.growthRange}</LabeledList.Item>
              <LabeledList.Item label="Mutation Forecast">{pressureForecast.mutationRange}</LabeledList.Item>
              <LabeledList.Item label="Stability Forecast">{pressureForecast.stabilityRange}</LabeledList.Item>
            </LabeledList>
          )}
          <Button onClick={() => act('chem')}>Load Chemicals</Button>
          <Button onClick={() => act('power')}>{powerOn ? 'Stop' : 'Start'} Run</Button>
          <Button onClick={() => act('flush')}>Flush</Button>
          {!!requiresRoleConfirmation && !powerOn && (
            <NoticeBox warning mt={1}>
              High-risk profile detected. Launch is blocked until both CMO and RD confirm.
            </NoticeBox>
          )}
        </Section>

        <Section title="Mutation Planner">
          {(effects || []).map((effect, i) => (
            <Box key={i}>{effect.name} / Stage {effect.stage}</Box>
          ))}
          {(riskProfiles || pathways || []).map((profile, i) => (
            <Box key={profile.id || i} mt={0.5}>
              {profile.label || profile.name}
              {profile.dangerous ? ' ? HIGH RISK' : ''}
              {!!profile.riskType && ` (${profile.riskType})`}
              {!!profile.details && <Box color="label">{profile.details}</Box>}
            </Box>
          ))}
          {!!requiresRoleConfirmation && (
            <Stack mt={1}>
              <Stack.Item>
                <Button
                  icon={cmoConfirmed ? 'check' : 'id-badge'}
                  color={cmoConfirmed ? 'good' : undefined}
                  onClick={() => act('confirm_risk', { role: 'cmo', reason: cmoReason })}>
                  CMO {cmoConfirmed ? 'Confirmed' : 'Confirm'}
                </Button>
                {!cmoConfirmed && (
                  <Input
                    mt={0.5}
                    fluid
                    placeholder="CMO confirmation reason"
                    value={cmoReason}
                    onChange={(_, value) => setCmoReason(value)}
                  />
                )}
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={rdConfirmed ? 'check' : 'flask'}
                  color={rdConfirmed ? 'good' : undefined}
                  onClick={() => act('confirm_risk', { role: 'rd', reason: rdReason })}>
                  RD {rdConfirmed ? 'Confirmed' : 'Confirm'}
                </Button>
                {!rdConfirmed && (
                  <Input
                    mt={0.5}
                    fluid
                    placeholder="RD confirmation reason"
                    value={rdReason}
                    onChange={(_, value) => setRdReason(value)}
                  />
                )}
              </Stack.Item>
            </Stack>
          )}
          <Button mt={1} onClick={() => act('disk')}>Write Disk</Button>
        </Section>

        <Section title="Treatment Builder">
          <LabeledList>
            <LabeledList.Item label="Antibodies">{antibodies || 'None'}</LabeledList.Item>
          </LabeledList>
          {(pathogens || []).map((p, i) => (
            <Box key={i}>
              {p.name} ({p.spreadType})
              <Button ml={1} onClick={() => act('isolate', { reference: p.reference })}>Extract</Button>
            </Box>
          ))}
          <Button onClick={() => act('antibody')}>Isolate Antibodies</Button>
          <Button onClick={() => act('print')}>Print Report</Button>
        </Section>

        <Section title="Quarantine & Protocols">
          <NoticeBox>
            Route confirmed strains to containment, update access protocols, and publish triage guidance.
          </NoticeBox>
        </Section>

        <Section title="Audit Log">
          {!canReadAuditLog && (
            <NoticeBox warning>
              Read access is restricted to Security, CMO, and command staff.
            </NoticeBox>
          )}
          {!!canReadAuditLog && !(auditLog || []).length && (
            <NoticeBox>No audit entries yet.</NoticeBox>
          )}
          {!!canReadAuditLog && (auditLog || []).map((entry, i) => (
            <Section key={i} title={`${entry.timestamp} // ${entry.event}`} level={2}>
              <LabeledList>
                <LabeledList.Item label="Operator">{entry.operator}</LabeledList.Item>
                <LabeledList.Item label="Pressures">
                  Food: {entry.pressures?.food} / Radiation: {entry.pressures?.radiation} / Mutagen: {entry.pressures?.mutagen} / Toxins: {entry.pressures?.toxins}
                </LabeledList.Item>
                <LabeledList.Item label="Confirmation reason">{entry.confirmationReason}</LabeledList.Item>
                <LabeledList.Item label="Pharmaceutical release">{entry.pharmaceuticalRelease}</LabeledList.Item>
                <LabeledList.Item label="Sign-off">
                  CMO: {entry.confirmations?.cmo ? 'yes' : 'no'} / RD: {entry.confirmations?.rd ? 'yes' : 'no'}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
