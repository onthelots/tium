import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

// Supabase 클라이언트 초기화
const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_ANON_KEY')!
);

// 기존 Dart 코드의 로직을 그대로 구현한 함수
async function determineUserTypeId(answers: { [key: string]: string }): Promise<number> {
  const { experienceLevel, locationPreference, careTime, interestTags } = answers;

  // Dart 코드의 로직과 1:1 매칭
  if (experienceLevel === 'beginner') {
    if (locationPreference === 'window' && careTime === 'short' && interestTags === 'flower') {
      return 1; // 햇살을 사랑하는 당신
    } else if (locationPreference === 'bedroom' && careTime === 'short') {
      return 2; // 조용한 방의 동반자
    } else {
      return 3; // 스마트하게 돌보는 사람
    }
  }

  if (experienceLevel === 'intermediate') {
    if (interestTags === 'flower') return 4; // 꽃을 기다리는 사람
    if (interestTags === 'shape') return 5; // 성장에 집중하는 사람
    return 6; // 계절을 타는 로맨티스트
  }

  if (experienceLevel === 'expert') {
    if (careTime === 'plenty' && locationPreference === 'window') {
      return 7; // 식물 마스터
    } else if (interestTags === 'price') {
      return 8; // 가성비를 중시하는 관찰자
    } else {
      return 9; // 성장을 탐험하는 사람
    }
  }

  return 3; // fallback: 스마트하게 돌보는 사람
}


Deno.serve(async (req) => {
  // CORS preflight 요청 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // 요청 본문에서 답변 ID 목록을 가져옴
    const { answer_ids } = await req.json();
    if (!answer_ids || !Array.isArray(answer_ids) || answer_ids.length === 0) {
      throw new Error("answer_ids 배열이 필요합니다.");
    }

    // 답변 ID를 사용하여 각 답변의 상세 정보(value, question_order)를 가져옴
    const { data: answersData, error: answersError } = await supabase
      .from('onboarding_answers')
      .select('value, question:onboarding_questions(question_order)')
      .in('id', answer_ids);

    if (answersError) throw answersError;

    // question_order를 키로 사용하여 답변 value를 맵으로 변환
    const answerValues: { [key: string]: string } = {};
    const keyMap = ['experienceLevel', 'locationPreference', 'careTime', 'interestTags'];
    answersData.forEach(item => {
      const order = item.question.question_order;
      answerValues[keyMap[order - 1]] = item.value;
    });

    // 로직 함수를 호출하여 사용자 유형 ID를 결정
    const userTypeId = await determineUserTypeId(answerValues);

    // 결정된 ID로 user_types 테이블에서 최종 정보를 가져옴
    const { data: userTypeData, error: userTypeError } = await supabase
      .from('user_types')
      .select('*')
      .eq('id', userTypeId)
      .single();

    if (userTypeError) throw userTypeError;

    // 최종 사용자 유형 정보를 반환
    return new Response(JSON.stringify(userTypeData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
});
