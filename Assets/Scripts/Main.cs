using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class Main : MonoBehaviour {
	[SerializeField]
	private AudioSource m_audio;

	[SerializeField]
	private Material m_mat;

	private int m_resolution = 1024;
	private float m_lowFreqThreshold = 11025, m_midFreqThreshold = 22050, m_highFreqThreshold = 33075, m_high2FreqThreshold = 44100;
	private float m_lowEnhance = 1f, m_midEnhance = 1.5f, m_highEnhance = 2f, m_high2Enhance = 2.5f;


	// Use this for initialization
	void Start () {

	}

	// Update is called once per frame
	void Update () {
		float[] spectrum = m_audio.GetSpectrumData(m_resolution, 0, FFTWindow.BlackmanHarris);

		var deltaFreq = AudioSettings.outputSampleRate / m_resolution;
		float low = 0f, mid = 0f, high = 0f, high2 = 0f;

		for (var i = 0; i < m_resolution; ++i) {
			var freq = deltaFreq * i;
			if      (freq <= m_lowFreqThreshold)  low  += spectrum[i];
			else if (freq <= m_midFreqThreshold)  mid  += spectrum[i];
			else if (freq <= m_highFreqThreshold) high += spectrum[i];
			else if (freq <= m_high2FreqThreshold) high2 += spectrum[i];
		}

		low  *= m_lowEnhance;
		mid  *= m_midEnhance;
		high *= m_highEnhance;
		high2 *= m_high2Enhance;

		m_mat.SetFloat ("_noise",Mathf.Clamp(mid*0.5f,0.1f,0.5f));
		m_mat.SetFloat ("_noise2",Mathf.Clamp(low*0.5f,0.1f,0.5f));
		m_mat.SetFloat ("_noise3",Mathf.Clamp(high*0.5f,0.1f,0.5f));
	}
}
