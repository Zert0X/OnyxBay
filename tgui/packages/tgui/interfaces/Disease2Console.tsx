import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section, Stack, Tabs } from '../components';
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
    pathogens,
    pathogenPool,
    antibodies,
    effects,
    powerOn,
  } = data;

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
        </Section>

        <Section title="Mutation Planner">
          {(effects || []).map((effect, i) => (
            <Box key={i}>{effect.name} / Stage {effect.stage}</Box>
          ))}
          <Button onClick={() => act('disk')}>Write Disk</Button>
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
          <NoticeBox>
            Legacy NanoUI workflow retired. This unified console keeps all disease2 actions in a single contract.
          </NoticeBox>
        </Section>
      </Window.Content>
    </Window>
  );
};
