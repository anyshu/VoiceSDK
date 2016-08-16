package com.duoyi.dyvoicesdk;

import com.duoyi.dyvoicesdk.api.DyVoiceAPI;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;

public class MainActivity extends Activity {

	private Spinner spinner_codecid, spinner_samplerate;
	private EditText et_bitrate;
	private Button btn_start, btn_stop, btn_encode, btn_decode;

	private final String[] array_codecid = { "silk", "others" };
	private ArrayAdapter<String> adapter_codecid = null;

	private final String[] array_samplerate = { "8000", "11025", "16000", "22050", "44100" };
	private ArrayAdapter<String> adapter_samplerate = null;

	private enum CODEC_ID {
		kSilk, kothers
	};

	CODEC_ID m_codecid = null;

	private int m_samplerate = 0, m_bitrate = 0;
	private DyVoiceAPI m_voice_api = null;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		initView();
		setListeners();

		m_voice_api = new DyVoiceAPI();
	}

	private void initView() {
		// initialize Spinner
		adapter_codecid = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, array_codecid);
		adapter_codecid.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinner_codecid = (Spinner) findViewById(R.id.spinner_codecId);
		spinner_codecid.setAdapter(adapter_codecid);
		spinner_codecid.setOnItemSelectedListener(new OnItemSelectedListener() {

			@Override
			public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
				String selected_codecid = parent.getItemAtPosition(position).toString();
				for (int i = 0; i < array_codecid.length; i++) {
					if (selected_codecid.equals(array_codecid[i])) {
						CODEC_ID[] tmp_array_codecid = CODEC_ID.values();
						m_codecid = tmp_array_codecid[i];
					}
				}
			}

			@Override
			public void onNothingSelected(AdapterView<?> parent) {

			}
		});

		adapter_samplerate = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, array_samplerate);
		adapter_samplerate.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinner_samplerate = (Spinner) findViewById(R.id.spinner_sampleRate);
		spinner_samplerate.setAdapter(adapter_samplerate);
		spinner_samplerate.setSelection(2);
		spinner_samplerate.setOnItemSelectedListener(new OnItemSelectedListener() {

			@Override
			public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
				String selected_samplerate = parent.getItemAtPosition(position).toString();
				m_samplerate = Integer.parseInt(selected_samplerate);
			}

			@Override
			public void onNothingSelected(AdapterView<?> parent) {

			}

		});

		// initialize EditText
		et_bitrate = (EditText) findViewById(R.id.et_bitrate);

		// initialize Button
		btn_start = (Button) findViewById(R.id.btn_start);
		btn_stop = (Button) findViewById(R.id.btn_stop);
		btn_encode = (Button) findViewById(R.id.btn_encode);
		btn_decode = (Button) findViewById(R.id.btn_decode);
	}

	private void setListeners() {
		OnClickListener listener = new OnClickListener() {
			@Override
			public void onClick(View v) {
				switch (v.getId()) {
				case R.id.btn_start: {

				}
					break;
				case R.id.btn_stop: {
					if (m_voice_api != null) {
						m_voice_api.stop();
					}
				}
					break;
				case R.id.btn_encode: {
					if (m_voice_api != null) {
						m_bitrate = Integer.valueOf(et_bitrate.getText().toString());
						m_voice_api.setCodecParameter(m_codecid.ordinal(), m_samplerate, m_bitrate, 44100, false, false,
								1);
						m_voice_api.encodeTest();
					}
				}
					break;
				case R.id.btn_decode: {
					
				}
					break;

				default:
					break;
				}
			}
		};

		btn_start.setOnClickListener(listener);
		btn_stop.setOnClickListener(listener);
		btn_encode.setOnClickListener(listener);
		btn_decode.setOnClickListener(listener);
	}
}
